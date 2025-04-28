// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RWAInitialOffering is ERC721URIStorage, Ownable {
    uint256 public nextTokenId;

    constructor() ERC721("RealWorldAsset", "RWA") {}

    function mint(address to, string memory tokenURI) external onlyOwner {
        uint256 tokenId = nextTokenId;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        nextTokenId++;
    }
}
