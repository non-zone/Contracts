const StoryFactory = artifacts.require('StoryFactory');

module.exports = async (deployer, network, accounts) => {
  await deployer.deploy(
    StoryFactory,
    // '0x2CEF62C91Dd92FC35f008D1d6Ed08EADF64306bc',
    'StoryFactory',
    'STORIES',
    // '0x3E14dC1b13c488a8d5D310918780c983bD5982E7',
    // '0x6EeE6060f715257b970700bc2656De21dEdF074C',
    // '0x0aeaa1eddC6660d681cd757b08585c0f2a1EDb41'
  );
};
