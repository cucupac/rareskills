// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MatrixMultiplication} from "../src/MatrixMultiplication.sol";
import {PreCompiles} from "../src/libraries/PreCompiles.sol";

contract RationalMathTest is Test {
    // contracts
    MatrixMultiplication public matmul;

    // storage
    uint256 n = 3;

    struct ECPoint {
        uint256 x;
        uint256 y;
    }

    function setUp() public {
        matmul = new MatrixMultiplication();
    }

    function _getM() internal pure returns (uint256[] memory) {
        uint256[] memory m = new uint256[](9);

        for (uint256 i; i < m.length; i++) {
            m[i] = i + 1;
        }
        return m;
    }

    function _getS() internal view returns (ECPoint[] memory) {
        ECPoint memory G1 = ECPoint({x: 1, y: 2});

        ECPoint[] memory s = new ECPoint[](n);

        for (uint256 i; i < n; i++) {
            (uint256 x, uint256 y) = PreCompiles.mul(i + 2, G1.x, G1.y);
            s[i] = ECPoint({x: x, y: y});
        }
        return s;
    }
}
