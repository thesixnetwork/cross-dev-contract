// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";

library LibDiamond {

    // enum ItemStatus {Active,InActive,Pause,Other}
    // enum OrderStatus {OnProgress,Success,Other}

    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndSelectorPosition {
        address facetAddress;
        uint16 selectorPosition;
    }


    struct SwapInTicketStruct {
        // why it is string because it is address of other chain ( cosmos , stellar)
        string sourceAddr;
        address destAddr;
        string destMemoText;
        uint256 swapAmount;
        string ticket;
        string sourceChain;
        bool isExistTicket;
        address tokenAddress;
    }

    struct SwapOutTicketStruct {
        address sourceAddr;
        string destAddr;
        string destMemoText;
        uint256 swapAmount;
        uint256 feeNormalAmount;
        uint256 feePercentAmount;
        uint256 totalReceiveAmount;
        string destChain;
        string ticket;
        bool isExistTicket;
        address tokenAddress;
    }
    
    struct FeeStruct {
        address sourceAddr;
        string destAddr;
        string destMemoText;
        uint256 swapAmount;
        uint256 feeAmount;
        string destChain;
    }
    

    struct DiamondStorage {
        // function selector => facet address and selector position in selectors array
        mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
        bytes4[] selectors;
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;

        // Eternal Storage for General purpose
        mapping(bytes32 => uint) uIntStorage;
        mapping(bytes32 => address) addressStorage;
        mapping(bytes32 => string) stringStorage;
        mapping(bytes32 => bool) boolStorage;
        mapping(bytes32 => uint256[]) arrayUintStorage;
        
        // MockStruct[] mock;
        mapping(string => SwapInTicketStruct) SwapInTickets;
        mapping(string => SwapOutTicketStruct) SwapOutTickets;
        // ERC20SwapInStruct[] ERC20SwapIns;
        // ERC20SwapOutStruct[] ERC20SwapOuts;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    // Internal function version of diamondCut
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            IDiamondCut.FacetCutAction action = _diamondCut[facetIndex].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                addFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else {
                revert("LibDiamondCut: Incorrect FacetCutAction");
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        uint16 selectorCount = uint16(ds.selectors.length);
        require(_facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
        enforceHasContractCode(_facetAddress, "LibDiamondCut: Add facet has no code");
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.facetAddressAndSelectorPosition[selector].facetAddress;
            require(oldFacetAddress == address(0), "LibDiamondCut: Can't add function that already exists");
            ds.facetAddressAndSelectorPosition[selector] = FacetAddressAndSelectorPosition(_facetAddress, selectorCount);
            ds.selectors.push(selector);
            selectorCount++;
        }
    }

    function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        require(_facetAddress != address(0), "LibDiamondCut: Replace facet can't be address(0)");
        enforceHasContractCode(_facetAddress, "LibDiamondCut: Replace facet has no code");
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.facetAddressAndSelectorPosition[selector].facetAddress;
            // can't replace immutable functions -- functions defined directly in the diamond
            require(oldFacetAddress != address(this), "LibDiamondCut: Can't replace immutable function");
            require(oldFacetAddress != _facetAddress, "LibDiamondCut: Can't replace function with same function");
            require(oldFacetAddress != address(0), "LibDiamondCut: Can't replace function that doesn't exist");
            // replace old facet address
            ds.facetAddressAndSelectorPosition[selector].facetAddress = _facetAddress;
        }
    }

    function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        uint256 selectorCount = ds.selectors.length;
        require(_facetAddress == address(0), "LibDiamondCut: Remove facet address must be address(0)");
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            FacetAddressAndSelectorPosition memory oldFacetAddressAndSelectorPosition = ds.facetAddressAndSelectorPosition[selector];
            require(oldFacetAddressAndSelectorPosition.facetAddress != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
            // can't remove immutable functions -- functions defined directly in the diamond
            require(oldFacetAddressAndSelectorPosition.facetAddress != address(this), "LibDiamondCut: Can't remove immutable function.");
            // replace selector with last selector
            selectorCount--;
            if (oldFacetAddressAndSelectorPosition.selectorPosition != selectorCount) {
                bytes4 lastSelector = ds.selectors[selectorCount];
                ds.selectors[oldFacetAddressAndSelectorPosition.selectorPosition] = lastSelector;
                ds.facetAddressAndSelectorPosition[lastSelector].selectorPosition = oldFacetAddressAndSelectorPosition.selectorPosition;
            }
            // delete last selector
            ds.selectors.pop();
            delete ds.facetAddressAndSelectorPosition[selector];
        }
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamondCut: _init is address(0) but_calldata is not empty");
        } else {
            require(_calldata.length > 0, "LibDiamondCut: _calldata is empty but _init is not address(0)");
            if (_init != address(this)) {
                enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert("LibDiamondCut: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }

    // Support Interfaces
    function supportsInterface(bytes4 interfaceId) internal view returns (bool) {
        DiamondStorage storage ds = diamondStorage();
        return ds.supportedInterfaces[interfaceId];
    }
    function registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "Bridge: invalid interface id");
        DiamondStorage storage ds = diamondStorage();
        ds.supportedInterfaces[interfaceId] = true;
    }


    // Eternal internal functions
    // *** Getter Methods ***
    function getSwapOutTicket(string memory _ticket) internal view returns (SwapOutTicketStruct storage) {
        DiamondStorage storage ds = diamondStorage();
        return ds.SwapOutTickets[_ticket];
    }
     function getSwapInTicket(string memory _ticket) internal view returns (SwapInTicketStruct storage) {
        DiamondStorage storage ds = diamondStorage();
        return ds.SwapInTickets[_ticket];
    }

    function getUint(bytes32 _key) internal view returns(uint) {
        DiamondStorage storage ds = diamondStorage();
        return ds.uIntStorage[_key];
    }

    function getAddress(bytes32 _key) internal view returns(address) {
        DiamondStorage storage ds = diamondStorage();
        return ds.addressStorage[_key];
    }

    function getString(bytes32 _key) internal view returns(string memory) {
        DiamondStorage storage ds = diamondStorage();
        return ds.stringStorage[_key];
    }

    function getBool(bytes32 _key) internal view returns(bool) {
        DiamondStorage storage ds = diamondStorage();
        return ds.boolStorage[_key];
    }
    function getArrayUint(bytes32 _key) internal view returns(uint256[] storage) {
        DiamondStorage storage ds = diamondStorage();
        return ds.arrayUintStorage[_key];
    }

    // *** Setter Methods ***
    function setSwapOutTicket(string memory _ticket, SwapOutTicketStruct memory _ticketStruct) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.SwapOutTickets[_ticket] = _ticketStruct;
    }
    function setSwapInTicket(string memory _ticket, SwapInTicketStruct memory _ticketStruct) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.SwapInTickets[_ticket] = _ticketStruct;
    }

    function setUint(bytes32 _key, uint _value) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.uIntStorage[_key] = _value;
    }

    function setAddress(bytes32 _key, address _value) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.addressStorage[_key] = _value;
    }

    function setString(bytes32 _key, string memory _value) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.stringStorage[_key] = _value;
    }

    function setBool(bytes32 _key, bool _value) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.boolStorage[_key] = _value;
    }
    function setArrayUint(bytes32 _key, uint256[] memory _value) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.arrayUintStorage[_key] = _value;
    }
    function initialToken() internal {
        emit Transfer(address(0), diamondStorage().contractOwner, 0);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
}
