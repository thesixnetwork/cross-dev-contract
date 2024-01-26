// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

import { IDiamondCut } from "../interfaces/IDiamondCut.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";

contract DiamondCutFacet is IDiamondCut {
    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {
        // LibDiamond.enforceIsContractOwner();
        _enforceIsCutterOrOwner(msg.sender);
        LibDiamond.diamondCut(_diamondCut, _init, _calldata);

    }
    function _enforceIsCutterOrOwner(address _address) internal view{
        require(_getCutterAddress() == _address || _getOwnerAddress() == _address,"Bridge: You are not cutter.");
    }
    function _getCutterAddress() internal view returns(address){
        return LibDiamond.getAddress(keccak256(abi.encodePacked("CONTRACT","CUTTER","ROLE")));
    }
    function _getOwnerAddress() internal view returns(address){
        return LibDiamond.contractOwner();
    }
}
