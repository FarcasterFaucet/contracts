// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {Faucet} from "../src/Faucet.sol";

contract TestToken is ERC20, Ownable {
    constructor(address initialOwner) ERC20("MyToken", "MTK") Ownable(initialOwner) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

contract FaucetTest is Test {
    TestToken public token;
    Faucet public faucet;

    address constant FARCASTER_REGISTRY = 0x00000000Fc6c5F01Fc30151999387Bb99A9f489b;
    uint256 constant PERIOD_LENGHT = 1 minutes;
    uint256 constant PERCENTAGE_PER_PERIOD = 1e16; // 1%

    function setUp() public {
        token = new TestToken(msg.sender);

        faucet = new Faucet(token, FARCASTER_REGISTRY, PERIOD_LENGHT, PERCENTAGE_PER_PERIOD);

        token.mint(address(faucet), 100000 ether);
    }

    function testState() public view {
        assertEq(faucet.registry().idOf(0x61d91d53980517651f17c4e98E3be4e74952975e), 581235);
    }
}
