/** @type import('hardhat/config').HardhatUserConfig */

require("hardhat-deploy");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");

const GOERLI_RPC_URL = process.env.GOERLI_RPC_URL;
const GOERLI_PRIVATE_KEY = process.env.GOERLI_PRIVATE_KEY;
const GOERLI_PRIVATE_KEY_2 = process.env.GOERLI_PRIVATE_KEY_2;

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
console.log(ETHERSCAN_API_KEY);

module.exports = {
  solidity: "0.8.17",

  networks: {
    goerli: {
      url: GOERLI_RPC_URL,
      accounts: [GOERLI_PRIVATE_KEY, GOERLI_PRIVATE_KEY_2],
      chainId: 5,
      blockconfirmations: 4,
    },
  },

  namedAccounts: {
    deployer: {
      default: 0,
    },
    account2: {
      default: 1,
    },
  },

  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};
