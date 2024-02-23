// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IDepositFacet } from "../interfaces/IDepositFacet.sol";

contract DepositFacet is IDepositFacet {
    // oneToAlll
    // send an amount of native token to provided addresses with specified ratio

    function depositToAllWallet (
        address[] memory destinations,
        uint8[] memory ratio,
        uint sumRatio
    ) external payable override {

        // copy of amount
        uint amount = msg.value;

        // loop over destinations
        for (uint i = 0; i < destinations.length-1; i++) {
            uint256 _value = msg.value * ratio[i] / sumRatio;
            // minus the value from amount
            amount -= _value;
            // send amount * ratio[i] / 100 to destinations[i]
            payable(destinations[i]).transfer(_value);
            
        }
        // send the remaining amount to the last destination
        payable(destinations[destinations.length-1]).transfer(amount);
    }
}