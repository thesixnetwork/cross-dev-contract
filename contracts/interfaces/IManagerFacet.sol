// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


interface IManagerFacet {
    function claimYieldAllGas() external;

    function claimYieldMaxGas() external;

    function setEmergency(bool _flag)  external;

    function getEmergency() external view returns(bool);

    function setFee(string calldata _command, uint _bps) external;

    function getFee(string calldata _command) external view returns(uint);

    function setFeeWallet(address _wallet) external;

    function getFeeWallet() external view returns(address);
    
    function setUniversalRouter(address _contract) external;

    function getUniversalRouter() external view returns(address);
}