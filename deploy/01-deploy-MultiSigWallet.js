const { ethers, network } = require("hardhat");
const { devlopmentChains } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deployer, account2 } = await getNamedAccounts();
  const { log, deploy } = deployments;

  args = [[deployer, account2], 2];

  const contract = await deploy("MultiSigWallet", {
    from: deployer,
    args: args,
    log: true,
  });

  if (!devlopmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
    log("Verifying......");
    await verify(contract.address, args);
  }

  log("--------------------------------------------------------------------------");
};
