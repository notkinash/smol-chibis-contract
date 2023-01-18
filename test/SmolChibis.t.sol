// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/SmolChibis.sol";

contract SmolChibisTest is Test {
    SmolChibis public smolChibis;

    function setUp() public {
        smolChibis = new SmolChibis();
        smolChibis.toggleMint();
    }

    function testMint() public {
        uint256 quantity = 1;
        uint256 price = smolChibis.mintPrice() * quantity;
        //
        vm.prank(msg.sender);
        smolChibis.mint{value: price}(quantity);
        //
        assertEq(smolChibis.balanceOf(msg.sender), quantity);
    }

    function testMintMax() public {
        uint256 quantity = uint256(smolChibis.collectionSize());
        uint256 price = smolChibis.mintPrice() * quantity;
        //
        vm.prank(msg.sender);
        smolChibis.mint{value: price}(quantity);
        //
        assertEq(smolChibis.balanceOf(msg.sender), quantity);
    }

    function testFailMintMaxPlus1() public {
        uint256 quantity = uint256(smolChibis.collectionSize()) + 1;
        uint256 price = smolChibis.mintPrice() * quantity;
        //
        vm.prank(msg.sender);
        smolChibis.mint{value: price}(quantity);
        //
        assertEq(smolChibis.balanceOf(msg.sender), quantity);
    }

    function testGive() public {
        uint256 quantity = 1;
        //
        vm.prank(smolChibis.owner());
        smolChibis.give(msg.sender, quantity);
        //
        assertEq(smolChibis.balanceOf(msg.sender), quantity);
    }

    function testGiveMax() public {
        uint256 quantity = uint256(smolChibis.collectionSize());
        //
        vm.prank(smolChibis.owner());
        smolChibis.give(msg.sender, quantity);
        //
        assertEq(smolChibis.balanceOf(msg.sender), quantity);
    }

    function testFailGiveMaxPlus1() public {
        uint256 quantity = uint256(smolChibis.collectionSize()) + 1;
        //
        vm.prank(smolChibis.owner());
        smolChibis.give(msg.sender, quantity);
        //
        assertEq(smolChibis.balanceOf(msg.sender), quantity);
    }

    function testWithdraw() public {
        uint256 quantity = 1;
        uint256 price = smolChibis.mintPrice() * quantity;
        //
        vm.prank(smolChibis.owner());
        smolChibis.transferOwnership(msg.sender);
        //
        vm.prank(msg.sender);
        smolChibis.mint{value: price}(quantity);
        //
        vm.prank(msg.sender);
        smolChibis.withdraw();
        //
        assertEq(address(smolChibis).balance, 0);
    }

    function testSetMintPrice() public {
        vm.prank(smolChibis.owner());
        smolChibis.setMintPrice(3 ether);
        assertEq(smolChibis.mintPrice(), 3 ether);
    }

    function testSetCollectionSize() public {
        vm.prank(smolChibis.owner());
        smolChibis.setCollectionSize(100);
        assertEq(smolChibis.collectionSize(), 100);
    }

    function testSetBaseURI() public {
        vm.prank(smolChibis.owner());
        smolChibis.setBaseURI("ipfs://");
        assertEq(smolChibis.tokenURI(1), "ipfs://1.json");
    }
}