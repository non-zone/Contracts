# Short paper describing the design of Non-Zone's Tokenomics

## Abstract
Non-Zone's tokenomics includes:
- Story NFTs --> Upgradeable ERC721.
- h-SPACE --> Alpha token for the NFT hack.
- SPACE --> Distance-based token, distributed at the launch.
- SPACE is **the first Distance-Based Token (and use-case) associated to Storytelling, NFT & Geo-caching.**

## Terms
### Zones:
Geo-fenced areas of 96 M², the average distance covered by a person in 1 minute.
In each Zone there can be up to 16 stories.

### Story:
An NFT "pinned" on Non-Zone Map. Each Story is identified by:
- Title (up to 6 words)
- Description (the actual text of the Story)
- Snapshot (a picture/video associated to the Story)
- Type [Fiction (= a fictional event) or Memory (= a personal event associated to the place)]
- We use a Composable NFT structure, where each Story is a _parent NFT_, and each Interaction with that Story is _child NFT_. 
- _Child NFTs_ (Interactions) can be tracked on the Polygon network using TheGraph's Subgraph on MATIC.
- **Story NFTs are natively minted on Polygon.**

### Scarcity:
There are 15 billion M² of land in the world. If we consider: 
- 96 M² per Zone,
- 16 Stories per Zone,
- 15 000 000 000 M² of total area,
- 15 000 000 000 / 96 * 16 = 2 500 000 000 Stories
- By default, **we have 2.5 Billion stories** to be told, and to be added to the map.

### Zoners: 
Users who download the mobile app, and "pin" a new Story on the map.
Once a new Story receives its first interaction from a different user (_Explorer_),
a new Stream of SPACE (h-SPACE for this hack) will be opened towards Zoner's account.
This is made possible thanks to our integration with Superfluid, and its CFA (Constant Flow Agreement) feature.

### Explorer 
An User who reads, discovers and interacts with the stories on the map. 
We use the concept of _meaningful interaction_ to let Zoners and Explorers connect through a story located in a real-world spot. 
Examples of meaningful interactions are:
- Leave a comment/signature on the Wall (free)
- "Collect" the Story, as a composable NFT, in your Zone Passport (paid)
- "Tip" (the Zoner/Author) (free, 100% of tips go to the Author)
- "Add your Story" - the Explorer can add a Snapshot to the original Story, or continue it, adding a small chapter. 
It's a paid interaction, but the Contributor receives future shares of the profit based on the value of its Contribution.

## NFT Hack Distribution 
### h-SPACE (v0.1, NFT Hack)
- Only 500 h-SPACE (Hack SPACE) generated on Polygon.
- Zoners (Creators) can create and pin their first story for free.
- Once a new Story receives its first interaction from an _Explorer_,
a new Stream of h-SPACE is opened towards _Zoner_'s account.
- h-SPACE is necessary for creating additional stories (after the 1st):
1. I / 0
2. II / 4,5
3. III / 7
4. IV / 9
5. V / 10,5
6. VI / 11,5
7. VII / 13
8. XVIII / 13,5
9. IX / 14,5
10. X / 15
11. XI / 15,5
12. XII / 16
13. XIII / 17
14. XIV / 17,5
15. XV / 18
16. XVI / 18
- Each "Interaction" is determined (_mapped_) using *theGraph's MATIC Subgraph*
- Interactions are _child NFTs_ attached to the _parent NFT_ (the Story), this way we can keep track of them, and determine their value-added, and their ratio respect the total amount of Interactions.
- The first 50 users connecting a Wallet and customizing their account will receive 5 MATIC, which covers more or less 3 paid interactions.

### h-SPACE CFA on Superfluid:
- 1st 20 Stories receiving an external (paid) interaction will receive a continuous Stream of h-SPACE
- The conditions of the h-SPACE streams are based on a Constant Flow Agreement on Superfluid.
- Zoners may have multiple active Stories, but they can receive only 1 h-SPACE stream during this phase.
- h-SPACE Stream is based on:
1. 15 days of Distribution: _d-tot_
2. daily distribution to be streamed (all addresses): _dh-SPACE = tot h-SPACE * 2 / d-left_
3. daily Zoner's reward: _dh-SPACE / (s-Int / t-Int)_
