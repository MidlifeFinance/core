/*
 *  Midlife Finance SafeMath Library
 *
 *  Midlife Finance - https://midlife.finance
 *  Developer Team: Wingnut - MidlifeTrader
 *
 *  Adds overflow protection to math functions. Based on various other
 *  open source implementations.
 *
 *
 *  SPDX-License-Identifier: MIT
 */

pragma solidity ^0.8.4;

library SafeMath {
    // Adds two numbers together
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'Addition overflow');
        return c;
    }

    // Subtracts one number from the other
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'Subtraction overflow');
    }

    // Subtracts one number from the other
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    // Multiples two numbers together
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'Multiplication overflow');
        return c;
    }

    // Divides one number by the other
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, 'Division by zero');
        uint256 c = a / b;
        return c;
    }

    // Gives the remainder of dividing one number by the other
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, 'Modulus by zero');
        return a % b;
    }

    // Determines which is the smaller number
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // Gets the square root of a number
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}