pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import {
    ISuperfluid,
    ISuperToken,
    ISuperApp,
    ISuperAgreement,
    SuperAppDefinitions
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol"; //"@superfluid-finance/ethereum-monorepo/packages/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import {
    IConstantFlowAgreementV1
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";

import {
    SuperAppBase
} from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperAppBase.sol";

import "./StoryFactory.sol"

contract StoryInteractionFactory is ERC721, SuperAppBase {
    using Counters for Counters.Counter;

    /*
     * Superfluid contracts instances used for a 
     * distribution flow
     */
    ISuperfluid private _host; // host
    IConstantFlowAgreementV1 private _cfa; // the stored constant flow agreement class address
    ISuperToken private _spaceToken; // accepted token


    // TokenID counter for the NFT
    Counters.Counter private tokenId; // to keep track of the number of NFTs we have minted
   
    // The parent NFT contract instance
    StoryFactory private _stories;

    // the count of the active streams. 
    // The distribution shouldn't open more than 20 streams
    // for the first 20 stories with interactions 
    uint8 _activeStreamsCount;

    // mapping storyID -> [Interactions]
    mapping(uint256 => uint256[]) public storyInteractions;
    Interaction[] public interactions;

    uint256 storiesCount;
    uint daysLeft = 15;
    uint256 _deployemntDate;
    address _tokenOwner;

    struct Interaction {
        address creator;
        string props;
    }

    event StoryInteractionCreated(
        address interactionCreator,
        string props,
        uint256 storyTokenId
    );

    constructor(
        string memory _name,
        string memory _symbol,
        address hostAddress,
        address cfaAddress,
        address spaceTokenAddress,
        address storyFactoryAddress,
        address tokenOwner
    ) public ERC721(_name, _symbol) {
        _host = ISuperfluid(hostAddress);
        _cfa = IConstantFlowAgreementV1(cfaAddress);
        _spaceToken = ISuperToken(spaceTokenAddress);
        _stories = StoryFactory(storyFactoryAddress);
        _receiver = msg.sender;
        _deployemntDate = now;
        _activeStreams = 0;
        _tokenOwner = tokenOwner;

        uint256 configWord =
            SuperAppDefinitions.APP_LEVEL_FINAL |
                SuperAppDefinitions.BEFORE_AGREEMENT_CREATED_NOOP |
                SuperAppDefinitions.BEFORE_AGREEMENT_UPDATED_NOOP |
                SuperAppDefinitions.BEFORE_AGREEMENT_TERMINATED_NOOP;

        _host.registerApp(configWord);
    }

    // this function is responsible for minting the story NFT
    // it is the responsibility of the caller to pass the props json schema for ERC721Metadata (_props argument)
    function createStoryInteraction(
        string calldata _props,
        uint256 _storyTokenId
    ) external payable onlyExpected returns (uint256) {

        address owner = msg.owner;

        // mint the NFT
        uint256 newItemId = tokenIds.current();
        _mint(owner, newItemId);
        _setTokenURI(newItemId, _props);
        tokenIds.increment();

        // add to the parent story's mapping
        storyInteractions[_storyTokenId].push(newItemId);
        
        // start stream if it's not yet started and there are free active streams slots 
        address ownerOfTheStory = _stories.ownerOf(_storyTokenId)
        if(storyInteractions[_storyTokenId].length == 1 && _activeStreamsCount < 20) _createStream(ownerOfStory, 1)

        emit StoryInteractionCreated(newItemId, owner, _props, _storyTokenId);

        return newItemId;
    }

    function updateStreams() {
        // Daily update of the streams
        // 1. stop all streams 
        // 2. calculate the daily token amount 
        // 3. start the streams 
    }

    function getStoryInteractions(uint256 tokenId)
        public
        view
        returns (uint256[] memory)
    {
        return storyInteractions[tokenId];
    }

    function getDailyDistributionTokenAmount() internal returns (uint256[] memory) {
        uint currentDay = (deployemntDate - now) / 60 / 60 / 24;
        uint dailySpace = _spaceToken.balanceOf(_tokenOwner) / (15 - currentDay);
        return dailySpace * 1e18 / 24 / 3600;
    }

    function _createStream(address receiver, uint256 tokensAmount) internal {
        _host.callAgreement(
                _cfa,
                abi.encodeWithSelector(
                    _cfa.createFlow.selector,
                    _acceptedToken,
                    receiver,
                    tokensAmount,
                    new bytes(0)
                ),
                "0x"
            );
    }

    modifier onlyExpected(ISuperToken superToken, address agreementClass) {
        require(_isSameToken(superToken), "StoryInteractionFactory: not accepted token");
        require(_isCFAv1(agreementClass), "StoryInteractionFactory: only CFAv1 supported");
        _;
    }
}
