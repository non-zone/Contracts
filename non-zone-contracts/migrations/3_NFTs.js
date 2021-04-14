const StoryFactory = artifacts.require('StoryFactory');
const StoryInteractionFactory = artifacts.require('StoryInteractionFactory');
const SpaceToken = artifacts.require('SpaceToken');

const HOST = '0xEB796bdb90fFA0f28255275e16936D25d3418603';
const CFA = '0x49e565Ed1bdc17F3d220f72DF0857C26FA83F873';
const SPACE_TOKEN_MUMBAI= '0xB203A837C3F1455F53665CCb1C67c2F5ED2331F4';
// const STORY_FACTORY = '0x08D32D581847afD9F215CC212723cb477f8EF8d0';
 const STORY_FACTORY_MUMBAI = '0x9bb80a452388aF8c312519D50a59eFC5e6E3c478';


module.exports = async (deployer, network, accounts) => {


  await deployer.deploy(
    SpaceToken
  );

  await deployer.deploy(
    StoryFactory,
    'StoryFactory',
    'STORIES'
  );
  console.log(StoryFactory.address);

  await deployer.deploy(
    StoryInteractionFactory,
    'StoryInteractionFactory',
    'INTERACTIONS',
    HOST,
    CFA,
    // SPACE_TOKEN_MUMBAI,
    SpaceToken.address,
    // STORY_FACTORY_MUMBAI
    StoryFactory.address
  );
};
