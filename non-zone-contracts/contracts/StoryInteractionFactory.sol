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

import "./StoryFactory.sol";

contract StoryInteractionFactory is ERC721, SuperAppBase {
    using Counters for Counters.Counter;

    /*
     * Superfluid contracts instances used for a
     * distribution flow
     */
    ISuperfluid private host;
    IConstantFlowAgreementV1 private cfa;
    ISuperToken private spaceToken;

    // TokenID counter for the NFT
    Counters.Counter private tokenId; // to keep track of the number of NFTs we have minted

    // The parent NFT contract instance
    StoryFactory private stories;

    // the count of the active streams.
    // The distribution shouldn't open more than 20 streams
    // for the first 20 stories with interactions
    uint8 activeStreamsCount;

    mapping(uint256 => uint256[]) public storyInteractions;

    uint256 private storiesCount;
    uint256 private daysLeft = 15;
    uint256 private deployemntDate;
    address private tokenOwner;
    address private trustedForwarder;

    event StoryInteractionCreated(
        uint256 tokenId,
        address interactionCreator,
        string props,
        uint256 storyTokenId
    );

    constructor(
        string memory _name,
        string memory _symbol,
        address _hostAddress,
        address _cfaAddress,
        address _spaceTokenAddress,
        address _storyFactoryAddress,
        address _tokenOwner,
        address _trustedForwarder
    ) public ERC721(_name, _symbol) {
        host = ISuperfluid(_hostAddress);
        cfa = IConstantFlowAgreementV1(_cfaAddress);
        spaceToken = ISuperToken(_spaceTokenAddress);
        stories = StoryFactory(_storyFactoryAddress);
        deployemntDate = block.timestamp;
        activeStreamsCount = 0;
        tokenOwner = _tokenOwner;
        trustedForwarder = _trustedForwarder;

        uint256 configWord =
            SuperAppDefinitions.APP_LEVEL_FINAL |
                SuperAppDefinitions.BEFORE_AGREEMENT_CREATED_NOOP |
                SuperAppDefinitions.BEFORE_AGREEMENT_UPDATED_NOOP |
                SuperAppDefinitions.BEFORE_AGREEMENT_TERMINATED_NOOP;

        host.registerApp(configWord);
    }

    /**
     * return the sender of this call.
     * if the call came through our trusted forwarder, return the original sender.
     * otherwise, return `msg.sender`.
     * should be used in the contract anywhere instead of msg.sender
     */
    function _msgSender()
        internal
        view
        virtual
        override
        returns (address payable ret)
    {
        if (msg.data.length >= 24 && isTrustedForwarder(msg.sender)) {
            // At this point we know that the sender is a trusted forwarder,
            // so we trust that the last bytes of msg.data are the verified sender address.
            // extract sender address from the end of msg.data
            assembly {
                ret := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return msg.sender;
        }
    }

    // this function is responsible for minting the story NFT
    // it is the responsibility of the caller to pass the props json schema for ERC721Metadata (_props argument)
    function createStoryInteraction(
        string calldata _props,
        uint256 _storyTokenId
    ) external payable returns (uint256) {
        address owner = _msgSender();

        // mint the NFT
        uint256 newItemId = tokenId.current();
        _mint(owner, newItemId);
        _setTokenURI(newItemId, _props);
        tokenId.increment();

        // add to the parent story's mapping
        storyInteractions[_storyTokenId].push(newItemId);

        // start stream if it's not yet started and there are free active streams slots
        address ownerOfTheStory = stories.ownerOf(_storyTokenId);
        if (
            storyInteractions[_storyTokenId].length == 1 &&
            activeStreamsCount < 20
        ) _createStream(ownerOfTheStory, 1);

        emit StoryInteractionCreated(newItemId, owner, _props, _storyTokenId);

        return newItemId;
    }

    function getStoryInteractions(uint256 _tokenId)
        public
        view
        returns (uint256[] memory)
    {
        return storyInteractions[_tokenId];
    }

    function getDailyDistributionTokenAmount() internal returns (uint256) {
        uint256 currentDay = (deployemntDate - block.timestamp) / 60 / 60 / 24;
        uint256 dailySpace =
            spaceToken.balanceOf(tokenOwner) / (15 - currentDay);
        return (dailySpace * 1e18) / 24 / 3600;
    }

    function _createStream(address _receiver, uint256 _tokensAmount) internal {
        host.callAgreement(
            cfa,
            abi.encodeWithSelector(
                cfa.createFlow.selector,
                spaceToken,
                _receiver,
                _tokensAmount,
                new bytes(0)
            ),
            "0x"
        );
    }

    function isTrustedForwarder(address forwarder) public view returns (bool) {
        return forwarder == trustedForwarder;
    }
}
