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

contract StoryInteractionFactory is ERC721, SuperAppBase {
    using Counters for Counters.Counter;

    Counters.Counter private tokenIds; // to keep track of the number of NFTs we have minted
    Interaction[] public interactions;
    ISuperfluid private _host; // host
    IConstantFlowAgreementV1 private _cfa; // the stored constant flow agreement class address
    ISuperToken private _acceptedToken; // accepted token
    mapping(uint256 => uint256[]) public storyInteractions;
    uint256 storiesCount;
    uint daysLeft = 15;
    uint256 deployemntDate;

    struct Interaction {
        address creator;
        string props;
    }

    event StoryInteractionCreated(
        uint256 tokenId,
        address interactionCreator,
        string props,
        uint256 storyTokenId
    );

    constructor(
        string memory _name,
        string memory _symbol,
        ISuperfluid host,
        IConstantFlowAgreementV1 cfa,
        ISuperToken acceptedToken
    ) public ERC721(_name, _symbol) {
        _host = host;
        _cfa = cfa;
        _acceptedToken = acceptedToken;
        _receiver = msg.sender;
        deployemntDate = now;
        

        uint256 configWord =
            SuperAppDefinitions.APP_LEVEL_FINAL |
                SuperAppDefinitions.BEFORE_AGREEMENT_CREATED_NOOP |
                SuperAppDefinitions.BEFORE_AGREEMENT_UPDATED_NOOP |
                SuperAppDefinitions.BEFORE_AGREEMENT_TERMINATED_NOOP;

        _host.registerApp(configWord);
        _changeReceiver(msg.sender);
    }

    // this function is responsible for minting the story NFT
    // it is the responsibility of the caller to pass the props json schema for ERC721Metadata (_props argument)
    // _props must include 4 things:
    // find the schema definition to conform to here: https://eips.ethereum.org/EIPS/eip-721
    function createStoryInteraction(
        address sender,
        string calldata _props,
        uint256 _storyTokenId,
        address storyOwner
    ) external payable onlyExpected returns (uint256) {
        uint256 newItemId = tokenIds.current();
        _mint(sender, newItemId);
        _setTokenURI(newItemId, _props);
        tokenIds.increment();

        Interaction memory interaction =
            Interaction({creator: sender, props: _props});

        interactions.push(interaction);
        storyInteractions[_storyTokenId].push(newItemId);

        if (storyInteractions[_storyTokenId] == 0) storiesCount++;

        if (storiesCount > 1 & storiesCount < 22) _createStream(storyOwner);

        emit StoryInteractionCreated(newItemId, sender, _props, _storyTokenId);

        return newItemId;
    }

    function getStoryInteractions(uint256 _storyTokenId)
        public
        view
        returns (uint256[] memory)
    {
        return storyInteractions[_storyTokenId];
    }

    function getFlowTokenAmount() internal returns (uint256[] memory) {
        uint currentDay = (deployemntDate - now) / 60 / 60 / 24;
        uint dailySpace = 1000 / (15 - currentDay);
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

    // @dev Change the Receiver of the total flow
    // function _changeReceiver(address newReceiver) internal {
    //     require(newReceiver != address(0), "New receiver is zero address");
    //     require(
    //         !_host.isApp(ISuperApp(newReceiver)),
    //         "New receiver can not be a superApp"
    //     );
    //     if (newReceiver == _receiver) return;
    //     // @dev delete flow to old receiver
    //     (, int96 outFlowRate, , ) =
    //         _cfa.getFlow(_acceptedToken, address(this), _receiver);
    //     if (outFlowRate > 0) {
    //         _host.callAgreement(
    //             _cfa,
    //             abi.encodeWithSelector(
    //                 _cfa.deleteFlow.selector,
    //                 _acceptedToken,
    //                 address(this),
    //                 _receiver,
    //                 new bytes(0)
    //             ),
    //             "0x"
    //         );
    //         _host.callAgreement(
    //             _cfa,
    //             abi.encodeWithSelector(
    //                 _cfa.createFlow.selector,
    //                 _acceptedToken,
    //                 newReceiver,
    //                 _cfa.getNetFlow(_acceptedToken, address(this)),
    //                 new bytes(0)
    //             ),
    //             "0x"
    //         );
    //     }
    //     _receiver = newReceiver;

    //     emit ReceiverChanged(_receiver);
    // }

    modifier onlyExpected(ISuperToken superToken, address agreementClass) {
        require(_isSameToken(superToken), "RedirectAll: not accepted token");
        require(_isCFAv1(agreementClass), "RedirectAll: only CFAv1 supported");
        _;
    }
}
