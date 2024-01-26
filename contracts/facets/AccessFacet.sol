// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { LibDiamond } from "../libraries/LibDiamond.sol";
import "../interfaces/IAccessFacet.sol";

contract AccessFacet is IAccessFacet {

    function setContractOwner(address _newOwner) external override{
        LibDiamond.enforceIsContractOwner();
        LibDiamond.setContractOwner(_newOwner);
    }
    function getContractOwner() public view override returns(address){
        return LibDiamond.contractOwner();
    }

    function setAddressForRole(string calldata _role,address _address) external override {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.setAddress(keccak256(abi.encodePacked("CONTRACT_ROLE",_role)),_address);
    }

    function getAddressForRole(string calldata _role) public view override returns(address address_) {
       address_ =  LibDiamond.getAddress(keccak256(abi.encodePacked("CONTRACT_ROLE",_role)));
    }
}   
