// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


interface IUniswapFacet {
    
    event QuickSwapUniversal(string _type, address _address, uint _amount, uint _fee);
    
    event QuickSwapV2In(string _type, address _address, uint _amount, uint _fee);

    event QuickSwapV2Out(string _type, address _address, uint _amount, uint _fee);

    function quickSwapUniversal(bytes memory _command, bytes[] memory _inputs) external payable;

    function quickSwapV2In(address _token0, address _token1, uint256 _deadline) external payable;

    function quickSwapV2Out(address _token0, address _token1, uint256 _amount, uint256 _deadline) external payable;

    function calculateFeeAndRemain(uint _amountIn) external view returns(uint[2] memory);

}