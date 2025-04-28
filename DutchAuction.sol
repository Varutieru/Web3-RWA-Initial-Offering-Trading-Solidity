// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract DutchAuction {
    IERC721 public nft;
    uint256 public nftId;

    address payable public seller;
    uint256 public startingPrice;
    uint256 public discountRate;
    uint256 public startAt;
    uint256 public endAt;
    bool public ended;

    constructor(address _nft, uint256 _nftId, uint256 _startingPrice, uint256 _discountRate, uint256 _duration) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startAt = block.timestamp;
        endAt = block.timestamp + _duration;

        require(_startingPrice >= _discountRate * _duration, "Starting price too low");
    }

    function getPrice() public view returns (uint256) {
        uint256 elapsed = block.timestamp - startAt;
        uint256 discount = discountRate * elapsed;
        return startingPrice - discount;
    }

    function buy() external payable {
        require(!ended, "Auction already ended");
        require(block.timestamp < endAt, "Auction expired");

        uint256 price = getPrice();
        require(msg.value >= price, "Not enough ETH");

        ended = true;
        nft.safeTransferFrom(seller, msg.sender, nftId);
        seller.transfer(price);

        // Refund extra if any
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }
}
