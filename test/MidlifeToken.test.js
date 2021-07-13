/*
 *  Midlife Token (MIDL) Test Script
 *
 *  Midlife Finance - https://midlife.finance
 *  Developer Team: Wingnut - MidlifeTrader
 *
 *  'truffle test' script for ensuring all the functionality of the smart contract is operating correctly.
 *
 *
 *  SPDX-License-Identifier: MIT
 */

const { assert } = require('chai');
const { time } = require('@openzeppelin/test-helpers');
const { ZERO_ADDRESS } = require('@openzeppelin/test-helpers/src/constants');
const MidlifeToken = artifacts.require('MidlifeToken');

require('chai').use(require('chai-as-promised')).should();

function tokens(n) {
    return web3.utils.toWei(n, 'Ether');
}

contract('MidlifeToken', ([owner, user1, user2]) => {
    let token;
    let result;

    before(async() => {
        token = await MidlifeToken.new();        
    });

    describe('Midlife Token (MIDL) : Smart Contract Test Suite', async() => {

        describe('[1] Deployment Tests', async() => {
            it('[1.01] Token has the correct symbol', async() => {
                result = await token.symbol();
                assert.equal(result.toString(), 'MIDL');
            });
            it('[1.02] Token has the correct name', async() => {
                result = await token.name();
                assert.equal(result.toString(), 'Midlife Token');
            });
            it('[1.03] Token has the correct decimals', async() => {
                result = await token.decimals();
                assert.equal(result.toString(), '18');
            });
            it('[1.04] Token has the correct owner', async() => {
                result = await token.getOwner();
                assert.equal(result.toString(), owner.toString());
            });


            it('[1.02] Token has the correct total supply', async() => {
                result = await token.totalSupply();
                assert.equal(result.toString(), tokens('100000000'));
            });
            it('[1.03] Deployer owns the entire total supply', async() => {
                result = await token.balanceOf(owner);
                assert.equal(result.toString(), tokens('100000000'));
            });
            it('[1.04] Can read the anti-dump state and enabled', async() => {
                result = await token.checkAntiDump();
                assert.equal(result.toString(), 'true');
            });
        });

        describe('[2] Basic Functionality Tests', async() => {
            it('[2.01] Deployer can transfer tokens successfully', async() => {
                await token.transfer(user1, tokens('100000'));
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), tokens('100000'));
                result = await token.balanceOf(owner);
                assert.equal(result.toString(), tokens('99900000'));
            });
            it('[2.02] User cannot transfer more tokens than they have', async() => {
                await token.transfer(user2, tokens('200000'), { from: user1 }).should.be.rejected;
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), tokens('100000'));
                result = await token.balanceOf(user2);
                assert.equal(result.toString(), '0');
            });
            it('[2.03] User can transfer tokens', async() => {
                await token.transfer(user2, tokens('100000'), { from: user1 });
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), '0');
                result = await token.balanceOf(user2);
                assert.equal(result.toString(), tokens('100000'));
            });
            it('[2.04] User cannot transfer anothers tokens', async() =>{
                await token.transferFrom(user2, user1, tokens('100000'), { from: user1 }).should.be.rejected;
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), '0');
                result = await token.balanceOf(user2);
                assert.equal(result.toString(), tokens('100000'));
            });
            it('[2.05] User can authorize another user to spend tokens', async() => {
                await token.increaseAllowance(user1, tokens('100000'), { from: user2 });
            });
            it('[2.06] User can spent anothers when authorized', async() => {
                await token.transferFrom(user2, user1, tokens('100000'), { from: user1 });
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), tokens('100000'));
                result = await token.balanceOf(user2);
                assert.equal(result.toString(), '0');
            });
            it('[2.07] User can burn tokens by sending to address 0', async() => {
                await token.transfer(ZERO_ADDRESS, tokens('100000'), { from: user1 });
                result = await token.burnedTokens();
                assert.equal(result.toString(), tokens('100000'));
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), '0');
            });
            it('[2.08] Deployer cannot transfer from address 0', async() => {
                await token.transferFrom(ZERO_ADDRESS, user1, tokens('100000')).should.be.rejected;
                result = await token.burnedTokens();
                assert.equal(result.toString(), tokens('100000'));
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), '0');
            });
        });

        describe('[3] Anti Pump And Dump Tests', async() => {
            it('[3.01] Deployer can transfer tokens successfully', async() => {
                await token.transfer(user1, tokens('1000000'));
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), tokens('1000000'));
                result = await token.balanceOf(owner);
                assert.equal(result.toString(), tokens('98900000'));
            });
            it('[3.02] User cannot transfer more than 20% when owning more than 0.5% of supply', async() => {
                await token.transfer(user2, tokens('200001'), { from: user1 }).should.be.rejected;
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), tokens('1000000'));
                result = await token.balanceOf(user2);
                assert.equal(result.toString(), '0');
            });
            it('[3.03] User can transfer 20% when owning more than 0.5% of the supply', async() => {
                await token.transfer(user2, tokens('200000'), { from: user1 });
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), tokens('800000'));
                result = await token.balanceOf(user2);
                assert.equal(result.toString(), tokens('200000'));
            });
            it('[3.04] User cannot make a second transfer', async() => {
                await token.transfer(user2, tokens('200000'), { from: user1 }).should.be.rejected;
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), tokens('800000'));
                result = await token.balanceOf(user2);
                assert.equal(result.toString(), tokens('200000'));
            });
            it('[3.05] Time should move 25 hours forward', async() => {
                const timeThen = await time.latest();
                const ahead = (25 * 60 * 60) + 600;
                await time.increase(ahead);
                const timeNow = await time.latest();
                const diff = timeNow - timeThen;
                assert.isTrue(diff >= ahead);                
            });
            it('[3.06] User can make a second transfer', async() => {
                await token.transfer(user2, tokens('160000'), { from: user1 });                
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), tokens('640000'));
                result = await token.balanceOf(user2);
                assert.equal(result.toString(), tokens('360000'));
            });
            it('[3.07] User cannot make a third transfer', async() => {
                await token.transfer(user2, tokens('128000'), { from: user1 }).should.be.rejected;
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), tokens('640000'));
                result = await token.balanceOf(user2);
                assert.equal(result.toString(), tokens('360000'));
            });
            it('[3.08] User cannot disable anti dump', async() => {
                await token.disableAntiDump({ from: user1 }).should.be.rejected;
                result = await token.checkAntiDump();
                assert.equal(result.toString(), 'true');
            });
            it('[3.09] Deployer can disable anti dump', async() => {
                await token.disableAntiDump();
                result = await token.checkAntiDump();
                assert.equal(result.toString(), 'false');
            });
            it('[3.10] User can transfer rest of balance', async() => {
                await token.transfer(user2, tokens('640000'), { from: user1 });
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), '0');
                result = await token.balanceOf(user2);
                assert.equal(result.toString(), tokens('1000000'));
            });
        });

        describe('[4] Balance Locking Tests', async() => {
            it('[4.01] Deployer can transfer tokens successfully', async() => {
                await token.transfer(user1, tokens('2500000'));
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), tokens('2500000'));
                result = await token.balanceOf(owner);
                assert.equal(result.toString(), tokens('96400000'));
            });
            it('[4.02] User cannot lock 0 balance', async() => {
                await token.lockBalance('0', '60', { from: user1 }).should.be.rejected;
            });
            it('[4.03] User cannot lock for 0 days', async() => {
                await token.lockBalance(tokens('2000000'), '0', { from: user1 }).should.be.rejected;
            });
            it('[4.04] User can lock balance', async() => {
                await token.lockBalance(tokens('2000000'), '60', { from: user1 });
                result = await token.checkLockedBalance(user1);
                assert.equal(result.toString(), tokens('2000000'));         
            });
            it('[4.05] User cannot unlock balance', async() => {
                result = await token.unlockBalance({ from: user1 }).should.be.rejected;
            });
            it('[4.06] User cannot set a lower lock time', async() => {
                result = await token.lockBalance(tokens('1'), '1', { from: user1 }).should.be.rejected;            
            });
            it('[4.07] User cannot transfer locked tokens', async() => {
                await token.transfer(user2, tokens('2500000'), { from: user1 }).should.be.rejected;
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), tokens('2500000'));
                result = await token.balanceOf(user2);
                assert.equal(result.toString(), tokens('1000000'));
            });
            it('[4.08] User can transfer unlocked balance', async() => {
                await token.transfer(user2, tokens('500000'), { from: user1 });
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), tokens('2000000'));
                result = await token.balanceOf(user2);
                assert.equal(result.toString(), tokens('1500000'));
            });
            it('[4.09] User cannot transfer anymore - all should be locked', async() => {
                await token.transfer(user2, '1', { from: user1 }).should.be.rejected;
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), tokens('2000000'));
                result = await token.balanceOf(user2);
                assert.equal(result.toString(), tokens('1500000'));
            });
            it('[4.10] Time should move 59 days forward', async() => {
                const timeThen = await time.latest();
                const ahead = (59 * 24 * 60 * 60) + 600;
                await time.increase(ahead);
                const timeNow = await time.latest();
                const diff = timeNow - timeThen;
                assert.isTrue(diff >= ahead);
            });
            it('[4.11] User cannot unlock balance', async() => {
                result = await token.unlockBalance({ from: user1 }).should.be.rejected;
            });
            it('[4.12] Time should move 1 day forward', async() => {
                const timeThen = await time.latest();
                const ahead = (1 * 24 * 60 * 60) + 600;
                await time.increase(ahead);
                const timeNow = await time.latest();
                const diff = timeNow - timeThen;
                assert.isTrue(diff >= ahead);
            });
            it('[4.13] User can unlock balance', async() => {
                result = await token.unlockBalance({ from: user1 });
            });
            it('[4.14] User can transfer unlocked tokens', async() => {
                await token.transfer(user2, tokens('2000000'), { from: user1 });
                result = await token.balanceOf(user1);
                assert.equal(result.toString(), '0');
                result = await token.balanceOf(user2);
                assert.equal(result.toString(), tokens('3500000'));
            });
        });

        describe('[5] Contract Ownership Tests', async() => {
            it('[5.01] User cannot change ownership', async() => {
                await token.transferOwnership(user1, { from: user1 }).should.be.rejected;
                result = await token.owner();
                assert.equal(result.toString(), owner.toString());
            });
            it('[5.02] Owner can change ownership', async() => {
                await token.transferOwnership(user1);
                result = await token.owner();
                assert.equal(result.toString(), user1.toString());
            });
            it('[5.03] User cannot renounce ownership', async() => {
                await token.renounceOwnership({ from: user2 }).should.be.rejected;
                result = await token.owner();
                assert.equal(result.toString(), user1.toString());
            });
            it('[5.04] Owner can relinquish ownership', async() => {
                await token.renounceOwnership({ from: user1 });
                result = await token.owner();
                assert.equal(result.toString(), ZERO_ADDRESS.toString());
            });
        });
    });
})