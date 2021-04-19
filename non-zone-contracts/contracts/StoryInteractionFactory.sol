pragma solidity ^0.7.6;

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

import "./StoryFactory.sol";

contract StoryInteractionFactory is ERC721 {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    /*
     * Superfluid contracts instances used for a
     * distribution flow
     */
    ISuperfluid private host;
    IConstantFlowAgreementV1 private cfa;
    ISuperToken private hSpaceToken;

    // TokenID counter for the NFT
    // to keep track of the number of NFTs minted
    Counters.Counter private tokenId;

    // The parent NFT contract instance
    StoryFactory private stories;

    // the count of the active streams.
    // The distribution shouldn't open more than 20 streams
    uint8 public activeStreamsCount;

    mapping(uint256 => uint256[]) public storyInteractions;
    mapping(address => bool) public startedStream;

    address deployer;

    /* 
        This event is emited when a story interaction NFT is created
    */
    event StoryInteractionCreated(
        uint256 tokenId,
        address interactionCreator,
        string props,
        uint256 storyTokenId,
        bool openStream
    );

    constructor(
        string memory _name,
        string memory _symbol,
        address _hostAddress,
        address _cfaAddress,
        address _hSpaceTokenAddress,
        address _storyFactoryAddress
    ) public ERC721(_name, _symbol) {
        host = ISuperfluid(_hostAddress);
        cfa = IConstantFlowAgreementV1(_cfaAddress);
        hSpaceToken = ISuperToken(_hSpaceTokenAddress);
        stories = StoryFactory(_storyFactoryAddress);
        activeStreamsCount = 0;
        deployer = msg.sender;
    }

    /* 
        createStoryInteraction mints a new "child" of the original story NFT.
        If there are no open streams to the story owner and there haven't been opened 20 streams yet,
        the function opens a new one.
        The story owner will receive 25 HSPACE tokens in 15 days.
    */
    function createStoryInteraction(
        address owner,
        string calldata _props,
        uint256 _storyTokenId
    ) external payable {
        require(
            msg.sender == deployer,
            "This can be called only by the deployer of the contract"
        );

        // get the address of the story owner
        address ownerOfTheStory = stories.ownerOf(_storyTokenId);

        require(
            ownerOfTheStory != owner,
            "The owner of the story is not allowed to interact with their own stories."
        );

        // mint the interaction NFT
        uint256 newItemId = tokenId.current();
        _mint(owner, newItemId);
        _setTokenURI(newItemId, _props);
        tokenId.increment();

        bool openStream = false;

        // add to the parent story's mapping
        storyInteractions[_storyTokenId].push(newItemId);

        // check if
        // 1. there's already created stream to the story owner
        // 2. there are still empty slots for opening a stream
        // -> create a stream
        if (!startedStream[ownerOfTheStory] && activeStreamsCount < 20) {
            // _createStream(ownerOfTheStory);
            startedStream[ownerOfTheStory] = true;
            activeStreamsCount++;
            openStream = true;
        }

        // Emit event with the new NFT data and a value showing whether the stream for this user has been opened.
        emit StoryInteractionCreated(
            newItemId,
            owner,
            _props,
            _storyTokenId,
            openStream
        );
    }

    /**
        Creates SuperFluid constant agreement flow.
        It will be sending the recipient 25 tokens in period of 15 days.
     */
    function _createStream(address _receiver) internal {
        host.callAgreement(
            cfa,
            abi.encodeWithSelector(
                cfa.createFlow.selector,
                hSpaceToken,
                _receiver,
                uint256((25 * 1e18) / (15 / 24 / 3600)), // 25 tokens for 15 days
                new bytes(0)
            ),
            "0x"
        );
    }
}
