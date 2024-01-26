// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


interface IUniswapFacet {
    function quickSwap(bytes memory _command, bytes[] memory _inputs) external payable;

    function calculateFeeAndRemain(uint _amountIn) external view returns(uint[2] memory);
   
}