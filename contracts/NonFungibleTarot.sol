// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import {Base64} from "./libraries/Base64.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract NonFungibleTarot is ERC721URIStorage {
    // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 TOKEN_LIMIT = 200;

    string baseSvg =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 18px; }</style><rect width='100%' height='100%' fill='black' /><text x='10%' y='10%' class='base' dominant-baseline='middle' text-anchor='left'>";

    string[] arcana = [
        "The Fool",
        "The Magician",
        "The High Priestess",
        "The Empress",
        "The Emperor",
        "The Hierophant",
        "The Lovers",
        "The Chariot",
        "Justice",
        "The Hermit",
        "Wheel of Fortune",
        "Strength",
        "The Hanged Man",
        "Death",
        "Temperance",
        "The Devil",
        "The Tower",
        "The Star",
        "The Moon",
        "The Sun",
        "Judgement",
        "The World"
    ];

    string[] spreadOne = [
        "Past:",
        "Idea:",
        "Situation:",
        "Situation:",
        "You:",
        "Strength:",
        "You:"
    ];
    string[] spreadTwo = [
        "Present:",
        "Process:",
        "Obstacle:",
        "Action:",
        "The Other:",
        "Weakness:",
        "Path:"
    ];
    string[] spreadThree = [
        "Future:",
        "Outcome:",
        "Advice:",
        "Outcome:",
        "Relationship:",
        "Advice:",
        "Potential:"
    ];

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    // We need to pass the name of our NFTs token and it's symbol.
    constructor() ERC721("TarotNFT", "TAROT") {
        console.log("Here's my Jabberwock NFT contract!");
    }

    // I create a function to randomly pick a word from each array.
    function chooseSpread(uint256 tokenId) public view returns (uint256) {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(
            string(
                abi.encodePacked(
                    "SPREAD",
                    Strings.toString(tokenId),
                    Strings.toString(block.timestamp)
                )
            )
        );

        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % spreadOne.length;
        return rand;
    }

    // I create a function to randomly pick a word from each array.
    function drawCard(uint256 tokenId, uint256 which)
        public
        view
        returns (string memory)
    {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(
            string(
                abi.encodePacked(
                    "ARCANA",
                    Strings.toString(tokenId),
                    Strings.toString(which),
                    Strings.toString(block.timestamp)
                )
            )
        );

        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % arcana.length;
        string memory chosenArcana = arcana[rand];

        uint256 randTwo = random(
            string(
                abi.encodePacked(
                    "INVERTED?",
                    Strings.toString(tokenId),
                    Strings.toString(which),
                    Strings.toString(block.timestamp)
                )
            )
        );
        randTwo = randTwo % 7;

        string memory isInverted = randTwo > 5 ? ", Inverted" : "";

        return string(abi.encodePacked(chosenArcana, isInverted));
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    // A function our user will hit to get their NFT.
    function tarotSpread() public {
        // Get the current tokenId, this starts at 0.
        uint256 newItemId = _tokenIds.current();

        require(
            newItemId < TOKEN_LIMIT,
            "Token limit has alreday been reached!"
        );

        // We go and randomly grab one word from each of the three arrays.
        uint256 spread = chooseSpread(newItemId);
        string memory cardOne = drawCard(newItemId, 1);
        string memory cardTwo = drawCard(newItemId, 2);
        string memory cardThree = drawCard(newItemId, 3);

        string memory combinedWord = string(
            abi.encodePacked(
                "<tspan x='10%' dy='0em'>",
                spreadOne[spread],
                " ",
                cardOne,
                "</tspan>",
                "<tspan x='10%' dy='1.6em'>",
                spreadTwo[spread],
                " ",
                cardTwo,
                "</tspan>",
                "<tspan x='10%' dy='1.6em'>",
                spreadThree[spread],
                " ",
                cardThree,
                "</tspan>"
            )
        );

        string memory finalSvg = string(
            abi.encodePacked(baseSvg, combinedWord, "</text></svg>")
        );

        string memory name = string(
            abi.encodePacked("Tarot Spread #", Strings.toString(newItemId))
        );

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        name,
                        '", "description": "Tarot spreads on the blockchain.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        // Actually mint the NFT to the sender using msg.sender.
        _safeMint(msg.sender, newItemId);

        // Set the NFTs data.
        _setTokenURI(newItemId, finalTokenUri);

        console.log(
            "Did a tarot spread w/ ID %s for %s",
            newItemId,
            msg.sender
        );

        // Increment the counter for when the next NFT is minted.
        _tokenIds.increment();

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}
