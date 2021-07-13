/*
 *  Midlife Finance Context Contract
 *
 *  Midlife Finance - https://midlife.finance
 *  Developer Team: Wingnut - MidlifeTrader
 *
 *  Provides a wrapper to get the message sender and data
 *  fields. Based on various other open source implementations.
 *
 *
 *  SPDX-License-Identifier: MIT
 */

pragma solidity ^0.8.4;

abstract contract Context {
    // Returns the address of the sender
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    // Returns the message data
    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}