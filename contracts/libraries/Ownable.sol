/*
 *  Midlife Finance Ownable Contract
 *
 *  Midlife Finance - https://midlife.finance
 *  Developer Team: Wingnut - MidlifeTrader
 *
 *  Provides ownership of a contract to allow functionality
 *  to be restricted. Based on various other open source 
 *  implementations.
 *
 *
 *  SPDX-License-Identifier: MIT
 */

pragma solidity ^0.8.4;

import './Context.sol';

abstract contract Ownable is Context {
    address private _owner;                 // The address that owns the contract

    // Emitted when the ownership of the contract changes
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Constructor to set parameters on contract creation
    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    // Returns the current owner of the contract
    function owner() public view returns (address) {
        return _owner;
    }

    // Throws error when account is not the owner
    modifier onlyOwner() {
        require(_owner == _msgSender(), "You are not the contract owner!");
        _;
    }

    // Renounces ownership and leaves the contract with no owner
    function renounceOwnership() public onlyOwner {
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));        
    }

    // Transfers ownership to a new address
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address. Renounce ownership instead!");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}