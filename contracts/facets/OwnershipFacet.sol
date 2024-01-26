// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { LibDiamond } from "../libraries/LibDiamond.sol";
import { IERC173 } from "../interfaces/IERC173.sol";

contract OwnershipFacet is IERC173 {
    event EventOwnershipTransferred(address indexed previousOwner, address indexed newOwner); // Declare the event

    function transferOwnership(address _newOwner) external override {
        address previousOwner = LibDiamond.contractOwner(); // Store the previous owner

        LibDiamond.enforceIsContractOwner();
        LibDiamond.setContractOwner(_newOwner);
        emit OwnershipTransferred(previousOwner, _newOwner); // Emit the event
    }

    function owner() external override view returns (address owner_) {
        owner_ = LibDiamond.contractOwner();
    }
}
