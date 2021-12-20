const StoreOfThing = artifacts.require('StoreOfThing');

module.exports = async (deployer, accounts) => {
  await deployer.deploy(StoreOfThing, accounts[0], { from: accounts[0] });
};