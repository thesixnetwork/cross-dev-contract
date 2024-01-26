// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


interface IAccessFacet {
    
    function setContractOwner(address _newOwner) external;
    function getContractOwner() external returns(address);

    function setAddressForRole(string calldata _role,address _address) external;
    function getAddressForRole(string calldata _role) external view returns(address address_) ;
}