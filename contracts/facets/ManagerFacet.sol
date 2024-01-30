// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { LibDiamond } from "../libraries/LibDiamond.sol";
import "../interfaces/IManagerFacet.sol";
import "../interfaces/IAccessFacet.sol";
import "../interfaces/IERC20.sol";

contract ManagerFacet is IManagerFacet {
    event SetEmergency(bool _flag);
    event SetFee(string _command, uint _bps);

    string private constant _MANAGER_ROLE_KEY = "MANAGER_ROLE";

    modifier onlyManagerOrOwner {
        address feeManagerAddr = IAccessFacet(address(this)).getAddressForRole(_MANAGER_ROLE_KEY);
        require(msg.sender == feeManagerAddr || msg.sender == LibDiamond.contractOwner(), "ManagerFacet: Only fee manager or Owner");
        _;
    }

    /* set fee for each commands with bps as :
        bps 1,000,000 = 100%
        bps 10,000 = 1%
    */

    /* mapping command to sha256(command)
        8ead0c3b203539fe29bd2cbf29abc1a5d04a92043c7e4a30959a2d154a028ef2 = QUICK_SWAP
    */
    
    function setEmergency(bool _flag)  external onlyManagerOrOwner {
        LibDiamond.setBool(keccak256(abi.encodePacked("EMERGENCY_BRIDGE")),_flag);
        emit SetEmergency(_flag);
    }
    function getEmergency() public view returns(bool) {
        return LibDiamond.getBool(keccak256(abi.encodePacked("EMERGENCY_BRIDGE")));
    }

    function setFee(string calldata _command, uint _bps) external onlyManagerOrOwner {
        require(_bps >= 0 && _bps <= 1000000, "bps is out of ranges");
        LibDiamond.setUint(keccak256(abi.encodePacked("FEE",_command)),_bps);
        emit SetFee(_command, _bps);
    }

    function getFee(string calldata _command) public view returns(uint) {
        return LibDiamond.getUint(keccak256(abi.encodePacked("FEE",_command)));
    }

    function setFeeWallet(address _wallet) external onlyManagerOrOwner {
        LibDiamond.setAddress(keccak256(abi.encodePacked("FEE_WALLET")), _wallet);
    }

    function getFeeWallet() public view returns(address) {
        return LibDiamond.getAddress(keccak256(abi.encodePacked("FEE_WALLET")));
    }

    function setUniversalRouter(address _contract) external onlyManagerOrOwner {
        LibDiamond.setAddress(keccak256(abi.encodePacked("UNIVERSAL_ROUTER_ADDR")), _contract);
    }

    function getUniversalRouter() public view returns(address) {
        return LibDiamond.getAddress(keccak256(abi.encodePacked("UNIVERSAL_ROUTER_ADDR")));
    }

    function setV2Router(address _contract) external onlyManagerOrOwner {
        LibDiamond.setAddress(keccak256(abi.encodePacked("V2_ROUTER_ADDR")), _contract);
    }

    function getV2Router() public view returns(address) {
        return LibDiamond.getAddress(keccak256(abi.encodePacked("V2_ROUTER_ADDR")));
    }

    function setApproveToPermit2(address _token, address _spender, uint48 _expiration) external onlyManagerOrOwner {
        (bool successExecute, ) = address(0x000000000022D473030F116dDEE9F6B43aC78BA3).call(abi.encodeWithSignature("approve(address,address,uint160,uint48)", _token, _spender, type(uint160).max, _expiration));
        require(successExecute, "Failed to set approve at Permit2");
    }
  

}
