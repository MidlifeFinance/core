/*
 *  Midlife Finance BEP20 Interface
 *
 *  Midlife Finance - https://midlife.finance
 *  Developer Team: Wingnut - MidlifeTrader
 *
 *  Defines the interface as required by the BEP20 standard.
 *  Based on various other open source implementations.
 *
 *
 *  SPDX-License-Identifier: MIT
 */

pragma solidity ^0.8.4;

interface IBEP20 {
    // Return the total supply in existance
    function totalSupply() external view returns (uint256);

    // Returns the number of decimals used by the token
    function decimals() external view returns (uint8);

    // Returns the token's symbol
    function symbol() external view returns (string memory);

    // Returns the name of the token
    function name() external view returns (string memory);

    // Returns the owner of the token
    function getOwner() external view returns (address);

    // Returns the balance of an account
    function balanceOf(address account) external view returns (uint256);

    // Transfers tokens from the caller to the recipient
    function transfer(address recipient, uint256 amount) external returns (bool);

    // The allowance the spender is allowed to use on behalf of the owner
    function allowance(address owner, address spender) external view returns (uint256);

    // Sets the allowance that spender can use on behalf of the sender
    function approve(address spender, uint256 amount) external returns (bool);

    // Transfers from the sender to the recipient using the allowance mechanism
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // Emitted when tokens are transferred between wallets
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Emitted when approval is given to spend on behalf of a user
    event Approval(address indexed owner, address indexed spender, uint256 value);
}