const StoryFactory = artifacts.require('StoryFactory');
const StoryInteractionFactory = artifacts.require('StoryInteractionFactory');
const HSpaceToken = artifacts.require('HSpaceToken');

const DEPLOYER_ADDRESS = '0x2CEF62C91Dd92FC35f008D1d6Ed08EADF64306bc';
const HOST = '0xEB796bdb90fFA0f28255275e16936D25d3418603';
const CFA = '0x49e565Ed1bdc17F3d220f72DF0857C26FA83F873';
const SPACE_TOKEN_MUMBAI= '0xf91123D5e24913613206d4e2Facf2e024CC88bC0';
// const STORY_FACTORY = '0x08D32D581847afD9F215CC212723cb477f8EF8d0';
// unwrapped - 0x84742946013e04432615202d77b958A5F9538e72
 const STORY_FACTORY_MUMBAI = '0x3e19eE4B1EfF873c6132C7a5476f02F7E213eD4c';


module.exports = async (deployer, network, accounts) => {

  // await deployer.deploy(
  //   HSpaceToken,
  //   500
  // );

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
    SPACE_TOKEN_MUMBAI,
    StoryFactory.address
  );
};
