/*
 *  Midlife Finance Truffle Configuration File
 *
 *  Midlife Finance - https://midlife.finance
 *  Developer Team: Wingnut - MidlifeTrader
 *
 *  Defines the parameters for truffle.
 *  ** DEVELOPMENT ENVIRONMENT ONLY **
 *
 *
 *  SPDX-License-Identifier: MIT
 */

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "1337"
    },
  },
  compilers: {
    solc: {
      version: "0.8.4",
      optimizer: {
        enabled: true,
        runs: 200
      },
      evmVersion: "petersburg"
    }
  }
}