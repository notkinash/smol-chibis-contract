// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SmolChibis is ERC721ABurnable, ERC721AQueryable, Ownable, ReentrancyGuard {
    uint256 public mintPrice = 0.2 ether;

    // Limits

    uint8 public collectionSize = 222;

    // Control

    bool public mintAvailable = false;

    string private _defaultBaseURI = "";
    
    constructor() ERC721A("Smol Chibis", "CHBS") {}

    // Mint functions

    function mint(uint256 quantity) external payable {
        // Check if mint is available
        require(mintAvailable, "Mint isn't available yet");

        // Check if there is enough tokens available
        uint256 nextTotalMinted = _totalMinted() + quantity;
        require(nextTotalMinted <= collectionSize, "Sold out");

        // Check if minter is paying the correct price
        uint256 price = quantity * mintPrice;
        require(msg.value >= price, "Invalid price");

        _mint(msg.sender, quantity);
    }

    function give(address to, uint256 quantity) external onlyOwner {
        // Check if there is enough tokens available
        uint256 nextTotalMinted = _totalMinted() + quantity;
        require(nextTotalMinted <= collectionSize, "Sold out");

        _mint(to, quantity);
    }

    // Control functions

    function toggleMint() external onlyOwner {
        mintAvailable = !mintAvailable;
    }

    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
    }

    function setCollectionSize(uint8 newSize) external onlyOwner {
        collectionSize = newSize;
    }

    function setBaseURI(string calldata newURI) external onlyOwner {
        _defaultBaseURI = newURI;
    }

    // Special functions

    function withdraw() external onlyOwner nonReentrant {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }

    // Override functions

    function tokenURI(uint256 tokenId) public view override(ERC721A, IERC721A) returns (string memory) {
        return string(abi.encodePacked(_defaultBaseURI, _toString(tokenId), ".json"));
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }
}