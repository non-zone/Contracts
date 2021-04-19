const StoryFactory = artifacts.require('StoryFactory');
const StoryInteractionFactory = artifacts.require('StoryInteractionFactory');

const HOST = '0xEB796bdb90fFA0f28255275e16936D25d3418603';
const CFA = '0x49e565Ed1bdc17F3d220f72DF0857C26FA83F873';
// TODO: change the decimals of the supertoken when deploying on matic => ideally 4
const SPACE_TOKEN_MUMBAI= '0x5bc52B5c2d04ABf41c6AEfdb32862BEb50FABc68';

module.exports = async (deployer, network, accounts) => {

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
