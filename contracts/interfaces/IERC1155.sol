

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC1155 {
    
    
    function mint(address account, uint256 id, uint256 amount, bytes memory data) external;
}
