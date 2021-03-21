const StoryInteractionFactory = artifacts.require('StoryInteractionFactory');


module.exports = async (deployer, network, accounts) => {
  await deployer.deploy(
    StoryInteractionFactory,
    'StoryInteractionFactory',
    'INTERACTIONS'
  );
};
