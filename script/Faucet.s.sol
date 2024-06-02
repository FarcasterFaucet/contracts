// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";

import {Token} from "../src/Token.sol";
import {Faucet} from "../src/Faucet.sol";

contract FaucetScript is Script {
    Token public token;
    Faucet public faucet;

    // Token settings
    string constant NAME = "Beyond Venture Capital";
    string constant SYMBOL = unicode"F😠😫🤕";
    uint256 constant INITIAL_SUPPLY = 1000000000 ether; // 1B

    // Faucet settings
    address constant FARCASTER_REGISTRY = 0x00000000Fc6c5F01Fc30151999387Bb99A9f489b;
    uint256 constant PERIOD_LENGHT = 1 days;
    uint256 constant PERCENTAGE_PER_PERIOD = 1e15; // 0.1%

    function run() public {
        vm.startBroadcast();

        token = new Token(NAME, SYMBOL, INITIAL_SUPPLY);

        faucet = new Faucet(token, FARCASTER_REGISTRY, PERIOD_LENGHT, PERCENTAGE_PER_PERIOD);

        // Transfer 1M tokens to the faucet
        token.transfer(address(faucet), 900000000 ether); // 900M

        vm.stopBroadcast();
    }
}
