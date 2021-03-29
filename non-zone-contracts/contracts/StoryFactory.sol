//SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;

import "@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract StoryFactory is ERC721 {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenId; // to keep track of the number of NFTs we have minted
    constructor(
        string memory _name,
        string memory _symbol
     ) ERC721(_name, _symbol) 
     {}


    event StoryCreated(uint256 tokenId, address storyCreator, string props);

    // this function is responsible for minting the story NFT
    // it is the responsibility of the caller to pass the props json schema for ERC721Metadata (_props argument)
    // _props must include 4 things:
    // find the schema definition to conform to here: https://eips.ethereum.org/EIPS/eip-721
    function createStory(
        string calldata _props,
        bool _isMemory
    ) external payable returns (uint256) {
        address owner  = msg.sender;
        uint256 newItemId = tokenIds.current();
        _mint(owner, newItemId);
        _setTokenURI(newItemId, _props);
        tokenIds.increment();


        emit StoryCreated(newItemId, owner, _props);

        return newItemId;
    }
}
