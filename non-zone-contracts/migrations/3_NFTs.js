const StoryFactory = artifacts.require('StoryFactory');
const StoryInteractionFactory = artifacts.require('StoryInteractionFactory');
const SpaceToken = artifacts.require('SpaceToken');

const HOST = '0x3E14dC1b13c488a8d5D310918780c983bD5982E7';
const CFA = '0x6EeE6060f715257b970700bc2656De21dEdF074C';
const SPACE_TOKEN = '0x176aF5305732854597082ce5c2171263b0bD7187';
const STORY_FACTORY = '0x08D32D581847afD9F215CC212723cb477f8EF8d0';

module.exports = async (deployer, network, accounts) => {

//   await deployer.deploy(
//     StoryFactory,
//     'StoryFactory',
//     'STORIES',
//     '0x86C80a8aa58e0A4fa09A69624c31Ab2a6CAD56b8'
//   );
  // console.log(SpaceToken.address);
  console.log(StoryFactory.address);

  await deployer.deploy(
    StoryInteractionFactory,
    'StoryInteractionFactory',
    'INTERACTIONS',
    HOST,
    CFA,
    SPACE_TOKEN,
    STORY_FACTORY
  );
};
