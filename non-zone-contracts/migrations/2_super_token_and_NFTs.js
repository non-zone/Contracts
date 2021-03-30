const StoryFactory = artifacts.require('StoryFactory');
const StoryInteractionFactory = artifacts.require('StoryInteractionFactory');
const SpaceToken = artifacts.require('SpaceToken');

module.exports = async (deployer, network, accounts) => {

  // await deployer.deploy(
  //   SpaceToken
  // );

  await deployer.deploy(
    StoryFactory,
    'StoryFactory',
    'STORIES',
    '0x86C80a8aa58e0A4fa09A69624c31Ab2a6CAD56b8'
  );
  // console.log(SpaceToken.address);
  console.log(StoryFactory.address);

  await deployer.deploy(
    StoryInteractionFactory,
    'StoryInteractionFactory',
    'INTERACTIONS',
    '0x3E14dC1b13c488a8d5D310918780c983bD5982E7',
    '0x6EeE6060f715257b970700bc2656De21dEdF074C',
    '0x0aeaa1eddC6660d681cd757b08585c0f2a1EDb41',
    '0x834F7401869F2e4E5a2FdfF327A8F5c5678068f4',
    '0x2CEF62C91Dd92FC35f008D1d6Ed08EADF64306bc',
    '0x86C80a8aa58e0A4fa09A69624c31Ab2a6CAD56b8'
  );
};
