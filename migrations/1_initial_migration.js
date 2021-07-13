/*
 *  Midlife Finance Truffle Migrations File
 *
 *  Midlife Finance - https://midlife.finance
 *  Developer Team: Wingnut - MidlifeTrader
 *
 *  Default migrations file for truffle.
 *
 *
 *  SPDX-License-Identifier: MIT
 */

const Migrations = artifacts.require("Migrations");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
