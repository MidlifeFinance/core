/*
 *  Midlife Finance BEP Contract
 *
 *  Midlife Finance - https://midlife.finance
 *  Developer Team: Wingnut - MidlifeTrader
 *
 *  Defines the basic parameters of a BEP20 token.
 *  Based on various other open source implementations.
 *
 *
 *  SPDX-License-Identifier: MIT
 */

pragma solidity ^0.8.4;

import '../Ownable.sol';
import '../Context.sol';
import './IBEP20.sol';
import '../SafeMath.sol';
import '../Address.sol';

abstract contract BEP20 is Context, Ownable, IBEP20 {
    using SafeMath for uint256;             // Add SafeMath to uint256 type
    using Address for address;              // Add Address to address type

    string private _name;                   // The name of the token
    string private _symbol;                 // The symbol of the token
    uint8 private _decimals;                // The decimals of the token
    uint256 private _totalSupply;           // The total supply of the token

    // Mapping tables for storing wallet balances and allowances
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Constructor to create the contract and set the parameters
    constructor (string memory tokenname, string memory tokensymbol, uint8 tokendecimals) {
        _name = tokenname;
        _symbol = tokensymbol;
        _decimals = tokendecimals;
    }

    // Returns the owner of the contract
    function getOwner() external override view returns (address) {
        return owner();
    }

    // Returns the name of the token
    function name() public override view returns (string memory) {
        return _name;
    }

    // Returns the decimals used by the token
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    // Returns the symbol of the token
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    // Returns the total supply of the token
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    // Returns the balance of an address
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    // Returns the total amount of burned tokens
    function burnedTokens() public view returns (uint256) {
        return balanceOf(address(0));
    }

    // Transfers a balance to another wallet
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    // Returns the allowance the sender can spend on behalf of the owner
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    // Approves the spender to spend an amount of the sender's tokens
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    // Method for transferring an amount on behalf of another address
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, 'Transfer amount exceeds allowance'));
        return true;
    }

    // Increases the allowance an address can spend on behalf of another
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    // Decreases the allowance an address can spend on behalf of another
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, 'Cannot decrease below zero'));
        return true;
    }

    // Mints an amount of the token and gives them to the contract owner
    function mint(uint256 amount) internal onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    // Mints an amount of tokens automatically adding the decimals
    function mintTokens(uint256 amount) internal onlyOwner returns (bool) {
        return mint(amount * 10**_decimals);
    }

    // Handles actually transferring tokens between wallets
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), 'Cannot transfer from 0 address');
        _balances[sender] = _balances[sender].sub(amount, 'Cannot transfer more tokens than you have');
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    // Handles actually minting tokens
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'Cannot mint to the zero address');
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    // Approves another address to spend on the owners behalf
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}