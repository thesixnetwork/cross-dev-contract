// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IUniswapV2Router01} from '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol';
import "../interfaces/IDexFacet.sol";
import "../interfaces/IAccessFacet.sol";
import "../interfaces/IManagerFacet.sol";
import "../interfaces/IERC20.sol";

contract DexFacet is IDexFacet {

    function quickSwapV2In(address _v2Router, address _token0, address _token1, uint256 _amountOutMin, uint256 _deadline) external payable {
        uint[2] memory nativeData = calculateFeeAndRemain(msg.value);

        // Consider to store fee native ETH in smart contract
        address payable feeWallet = payable (IManagerFacet(address(this)).getFeeWallet());
        (bool successTransferFee, ) = feeWallet.call{value: nativeData[1]}("");
        require(successTransferFee, "Failed to send Ether");

        address[] memory path = new address[](2);
        path[0] = _token0;
        path[1] = _token1;

        IUniswapV2Router01(_v2Router).swapExactETHForTokens{value: nativeData[0]}(_amountOutMin, path, msg.sender, _deadline);
        
        // (bool successSwap, ) = address(v2Router).call{value: nativeData[0]}(abi.encodeWithSignature("swapExactETHForTokens(uint256,address[],address,uint256)", 0, [token0,token1], msg.sender, deadline));
        // require(successSwap, "Failed to swap");

        emit QuickSwapV2In("V2In", msg.sender, msg.value, nativeData[1]);
    }

    function quickSwapV2Out(address _v2Router, address _token0, address _token1, uint256 _amount, uint256 _amountOutMin, uint256 _deadline) external payable {
        IERC20 inputToken = IERC20(_token0);

        address[] memory path = new address[](2);
        path[0] = _token0;
        path[1] = _token1;

        require(inputToken.transferFrom(msg.sender, address(this), _amount), "transfer input token failed");

        uint256 allowance = inputToken.allowance(address(this), _v2Router);
        if(allowance < _amount) {
            inputToken.approve(_v2Router, type(uint256).max);
        }

        IUniswapV2Router01(_v2Router).swapExactTokensForETH(_amount, _amountOutMin, path, address(this), _deadline);
        uint[2] memory nativeData = calculateFeeAndRemain(address(this).balance);
        
        (bool successTransferEthSender, ) = msg.sender.call{value: nativeData[0]}("");
        require(successTransferEthSender, "Failed to send Ether to msg.sender");

        address payable feeWallet = payable (IManagerFacet(address(this)).getFeeWallet());
        (bool successTransferEthFee, ) = feeWallet.call{value: nativeData[1]}("");
        require(successTransferEthFee, "Failed to send Ether to fee wallet");

        emit QuickSwapV2Out("V2Out", msg.sender, nativeData[0], nativeData[1]);
    }

    function calculateFeeAndRemain(uint _amountIn) public view returns(uint[2] memory) {
        uint feeBps = IManagerFacet(address(this)).getFee("8ead0c3b203539fe29bd2cbf29abc1a5d04a92043c7e4a30959a2d154a028ef2");
        uint fee = (_amountIn * feeBps)/(1e6);
        uint remain = _amountIn - fee;
        uint[2] memory data = [remain, fee];
        return data;
    }

    function toBytes(bytes calldata _bytes, uint256 _arg) internal pure returns (bytes calldata res) {
        (uint256 length, uint256 offset) = toLengthOffset(_bytes, _arg);
        assembly {
            res.length := length
            res.offset := offset
        }
    }

    function toLengthOffset(bytes calldata _bytes, uint256 _arg)
        internal
        pure
        returns (uint256 length, uint256 offset)
    {
        uint256 relativeOffset;
        assembly {
            // The offset of the `_arg`-th element is `32 * arg`, which stores the offset of the length pointer.
            // shl(5, x) is equivalent to mul(32, x)
            let lengthPtr := add(_bytes.offset, calldataload(add(_bytes.offset, shl(5, _arg))))
            length := calldataload(lengthPtr)
            offset := add(lengthPtr, 0x20)
            relativeOffset := sub(offset, _bytes.offset)
        }
        require(_bytes.length >= length + relativeOffset, "SliceOutOfBounds");
    }
}