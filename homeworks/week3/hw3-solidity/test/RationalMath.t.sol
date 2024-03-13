// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {RationalMath} from "../src/RationalMath.sol";
import {PreCompiles} from "../src/libraries/PreCompiles.sol";

contract RationalMathTest is Test {
    RationalMath public rm;

    function setUp() public {
        rm = new RationalMath();
    }

    function test_RationalAdd() public {
        // Get points A and B
    }
}
