/*
 *  Midlife Token (MIDL) Smart Contract
 *
 *  Midlife Finance - https://midlife.finance
 *  Developer Team: Wingnut - MidlifeTrader
 *
 *  Smart contract that creates and manages the Midlife Token BEP20 token. 
 *  Includes time lockable balances and an anti pump-and-dump mechanic.
 *
 *
 *  SPDX-License-Identifier: MIT
 */

pragma solidity ^0.8.4;

import "./libraries/tokens/BEP20.sol";

contract MidlifeToken is BEP20 {
    using SafeMath for uint256;                     // Add SafeMath to uint256 type
    using Address for address;                      // Add Address to address type

    bool public antiDump = true;                    // Flag for controlling the anti pump and dump code
    mapping (address => uint256) previousSale;      // Table for tracking previous sales for anti dump code
    mapping (address => uint256) lockedBalances;    // Balances that are locked
    mapping (address => uint256) lockedUntil;       // Mapping for when locked balances are free

    // Constructor for creating the contract, defining parameters, and minting the supply
    constructor() BEP20('Midlife Token', 'MIDL', 18) { 
        mintTokens(100000000);
    }

    // Returns the current state of the anti pump and dump code
    function checkAntiDump() public view returns (bool) { 
        return antiDump;
    }

    // Disables the anti pump and dump code
    function disableAntiDump() public onlyOwner { 
        antiDump = false;
    }

    // Checks the locked balance of a wallet
    function checkLockedBalance(address wallet) public view returns (uint256) { 
        return lockedBalances[wallet];
    }

    // Checks the number of days a balance is locked
    function checkLockedDays(address wallet) public view returns (uint256) {
        return lockedUntil[wallet];
    }

    // Locks a balance for a set amount of time
    function lockBalance(uint256 amount, uint256 lockedDays) public {
        address sender = _msgSender();
        require((balanceOf(sender) - lockedBalances[sender]) >= amount, "Insufficient balance to lock");
        require(amount > 0, "Cannot lock 0 balance");
        require(lockedDays > 0, "Cannot lock for 0 days");
		uint256 newLock = block.timestamp.add(lockedDays * 1 days);
		require(newLock > lockedUntil[sender], "New lock time is before old lock time");
        lockedBalances[sender] = lockedBalances[sender].add(amount);
        lockedUntil[sender] = block.timestamp.add(lockedDays * 1 days);
    }

    // Unlocks a balance
    function unlockBalance() public {
        address sender = _msgSender();
        require(lockedBalances[sender] > 0, "No locked balance");
        require(block.timestamp > lockedUntil[sender], "Unlock period has not expired");
        lockedBalances[sender] = 0;
    }

    // Checks against locked balances
    function checkLocked(address sender, uint256 amount) private view returns (bool) {
        if (lockedBalances[sender] == 0) return true;
        if ((balanceOf(sender) - amount) >= lockedBalances[sender]) return true;
        return false;
    }

    // Checks if a transfer is valid
    function validTransfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(checkLocked(sender, amount), "Insufficient unlocked balance for transfer");

        // Check if antidump is enabled - owner has override - can always send as much as you want to burn
        if (antiDump && sender != owner() && recipient != address(0)) {            
            uint256 fromBalance = balanceOf(sender);            // Get the balance of the sender
            uint256 threshold = (totalSupply() * 5) / 1000;     // Calculate 0.5% of the supply
            
            // Check if the sender has more than the threshold and if so enforce 20% sold per 24 hours
            if (fromBalance >= threshold) {
                require(amount <= fromBalance / 5, "Anti Pump And Dump - Max sell 20% if you hold more than 0.5% of supply."); 
                require(block.timestamp - (previousSale[sender]) > 24 hours, "You must wait 24 hours before you may sell again.");
                previousSale[sender] = block.timestamp;
            }
        }
        return true;
    }

    // Transfer function to handling antidump and locked balances
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        address sender = _msgSender();
        require(validTransfer(sender, recipient, amount));
        return super.transfer(recipient, amount);
    }

    // Transfer From function to handling antidump and locked balances
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(validTransfer(sender, recipient, amount));
        return super.transferFrom(sender, recipient, amount);
    }
}