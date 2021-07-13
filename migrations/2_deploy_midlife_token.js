/*
 *  Midlife Token (MIDL) Deployment Script
 *
 *  Midlife Finance - https://midlife.finance
 *  Developer Team: Wingnut - MidlifeTrader
 *
 *  Deploment script for the Midlife Token (MIDL).
 *  ** DEVELOPMENT ENVIRONMENT ONLY **
 *
 *
 *  SPDX-License-Identifier: MIT
 */

const MidlifeToken = artifacts.require("MidlifeToken");
const wingnut = '0x29B272e91B89F63a00593e96eDC05DcAb52fBAb4';       // REPLACE WITH REAL ADDRESS FOR DEPLOYMENT
const midlifetrader = '0x72bc7895c8e18a557D8F512b1F712B2236b93dd2'; // REPLACE WITH REAL ADDRESS FOR DEPLOYMENT

module.exports = async function(deployer) {
    await deployer.deploy(MidlifeToken);
    const token = await MidlifeToken.deployed();
    await token.transfer(wingnut, '2500000000000000000000000');
    await token.transfer(midlifetrader, '2500000000000000000000000');
};
