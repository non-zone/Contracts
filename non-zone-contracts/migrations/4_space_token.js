const SpaceToken = artifacts.require('SpaceToken');


module.exports = async (deployer, network, accounts) => {
  await deployer.deploy(
    SpaceToken
  );
};