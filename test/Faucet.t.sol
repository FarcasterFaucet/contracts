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
    // fork env
    uint256 OP_FORK_BLOCK_NUMBER = 120797050;
    string OP_RPC_URL = vm.envOr("OP_RPC_URL", string("https://optimism.quiknode.pro/"));

    TestToken public token;
    Faucet public faucet;

    address constant FARCASTER_REGISTRY = 0x00000000Fc6c5F01Fc30151999387Bb99A9f489b;
    uint256 constant PERIOD_LENGHT = 1 minutes;
    uint256 constant PERCENTAGE_PER_PERIOD = 1e16; // 1%

    address constant user = 0x1656E1595f84dE4644a5015563F23F9B1CF83bfc;
    address constant user2 = 0x45C11d6e1721afD2da754cdD3C0EBD32f62c2bB9;
    address constant user3 = 0xD0EacC138949285D6267454ED125130A49e4253A;

    function setUp() public {
        vm.createSelectFork(OP_RPC_URL, OP_FORK_BLOCK_NUMBER);

        token = new TestToken(address(this));

        faucet = new Faucet(token, FARCASTER_REGISTRY, PERIOD_LENGHT, PERCENTAGE_PER_PERIOD);

        token.mint(address(faucet), 100000 ether);
    }

    function testClaimAndOrRegister() public {
        vm.startPrank(user);
        faucet.claimAndOrRegister();

        skip(60);

        faucet.claimAndOrRegister();

        assertEq(token.balanceOf(user), 1000 ether);
    }

    function testFailWhenClaimMoreThanOnce() public {
        vm.startPrank(user);
        faucet.claimAndOrRegister();

        skip(60);

        faucet.claim();
        faucet.claim();
    }

    function testMultipleClaims() public {
        vm.prank(user);
        faucet.claimAndOrRegister();

        vm.prank(user2);
        faucet.claimAndOrRegister();

        skip(60);

        vm.prank(user);
        faucet.claim();

        vm.prank(user2);
        faucet.claim();

        assertEq(token.balanceOf(user), 500 ether);
        assertEq(token.balanceOf(user2), 500 ether);
    }

    function testClaimOnSecondPeriod() public {
        vm.prank(user);
        faucet.claimAndOrRegister();

        vm.prank(user2);
        faucet.claimAndOrRegister();

        skip(60);

        vm.prank(user);
        faucet.claimAndOrRegister();

        vm.prank(user2);
        faucet.claimAndOrRegister();

        vm.prank(user3);
        faucet.claimAndOrRegister();

        skip(60);

        vm.prank(user);
        faucet.claim();

        vm.prank(user2);
        faucet.claim();

        vm.prank(user3);
        faucet.claim();

        assertEq(token.balanceOf(user), 830 ether);
        assertEq(token.balanceOf(user2), 830 ether);
        assertEq(token.balanceOf(user3), 330 ether);
    }
}
