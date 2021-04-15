const StoryFactory = artifacts.require('StoryFactory');
const HSpaceToken = artifacts.require('HSpaceToken');

module.exports = async (deployer, network, accounts) => {
  await deployer.deploy(
    HSpaceToken
  );
};
