// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Faucet} from "../src/Faucet.sol";

contract FaucetTest is Test {
    Faucet public faucet;

    function setUp() public {
        faucet = new Faucet();
        // faucet.setNumber(0);
    }

    // function test_Increment() public {
    //     faucet.increment();
    //     assertEq(faucet.number(), 1);
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     faucet.setNumber(x);
    //     assertEq(faucet.number(), x);
    // }
}
