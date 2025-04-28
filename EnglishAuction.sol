// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract EnglishAuction {
    IERC721 public nft;
    uint256 public nftId;

    address payable public seller;
    uint256 public endAt;
    bool public ended;

    address public highestBidder;
    uint256 public highestBid;
    mapping(address => uint256) public bids;

    constructor(address _nft, uint256 _nftId, uint256 _startingBid, uint256 _duration) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
        highestBid = _startingBid;
        endAt = block.timestamp + _duration;

        // Seller must approve this contract first!
    }

    function bid() external payable {
        require(block.timestamp < endAt, "Auction ended");
        require(msg.value > highestBid, "Bid too low");

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid; // Refund previous highest bidder
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
    }

    function withdraw() external {
        uint256 bal = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);
    }

    function end() external {
        require(block.timestamp >= endAt, "Auction not yet ended");
        require(!ended, "Already ended");
        ended = true;

        if (highestBidder != address(0)) {
            nft.safeTransferFrom(seller, highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            // No bids, seller keeps NFT
        }
    }
}
