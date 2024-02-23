// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


interface IDepositFacet {
    function depositToAllWallet (address[] memory destinations, uint8[] memory ratio, uint sumRatio) external payable;
}