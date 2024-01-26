// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import "../interfaces/IUniswapFacet.sol";
import "../interfaces/IAccessFacet.sol";
import "../interfaces/IManagerFacet.sol";
import "../interfaces/IERC20.sol";

contract UniswapFacet is IUniswapFacet {
    event QuickSwap(address _address, uint _amount, uint _fee);

    function quickSwap(bytes memory _command, bytes[] memory _inputs) external payable {
        uint feeBps = IManagerFacet(address(this)).getFee("8ead0c3b203539fe29bd2cbf29abc1a5d04a92043c7e4a30959a2d154a028ef2");
        uint fee = (msg.value * feeBps)/(1e6);
        uint remainNative = msg.value - fee;
        address payable feeWallet = payable (IManagerFacet(address(this)).getFeeWallet());
        (bool successTransferFee, ) = feeWallet.call{value: fee}("");
        require(successTransferFee, "Failed to send Ether");
        address universalRouter = IManagerFacet(address(this)).getUniversalRouter();
        (bool successExecute, ) = address(universalRouter).call{value: remainNative}(abi.encodeWithSignature("execute(bytes,bytes[])", _command, _inputs));
        require(successExecute, "Failed to execute");

        emit QuickSwap(msg.sender, msg.value, fee);
    }

    function calculateFeeAndRemain(uint _amountIn) public view returns(uint[2] memory) {
        uint feeBps = IManagerFacet(address(this)).getFee("8ead0c3b203539fe29bd2cbf29abc1a5d04a92043c7e4a30959a2d154a028ef2");
        uint fee = (_amountIn * feeBps)/(1e6);
        uint remain = _amountIn - fee;
        uint[2] memory data = [remain, fee];
        return data;
    }
}
