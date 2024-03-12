// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {PreCompiles} from "./libraries/PreCompiles.sol";

contract RationalMath {
    // constants
    uint256 public constant CURVE_ORDER = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 public constant G1_X = 1;
    uint256 public constant G1_Y = 2;

    struct ECPoint {
        uint256 x;
        uint256 y;
    }

    /// @dev claim: “I know two rational numbers that add up to num/den”
    function rationalAdd(ECPoint calldata A, ECPoint calldata B, uint256 num, uint256 den) public view returns (bool) {
        // 1. Add points A and B to get point proposal sum
        (uint256 proposed_sum_x, uint256 proposed_sum_y) = PreCompiles.add(A.x, A.y, B.x, B.y);

        // 2. Construct the point num/den * G1
        uint256 den_mod_inv = PreCompiles.modExp(den, CURVE_ORDER - 2, CURVE_ORDER);
        (uint256 den_inv_x, uint256 den_inv_y) = PreCompiles.mul(den_mod_inv, G1_X, G1_Y);
        (uint256 c_x, uint256 c_y) = PreCompiles.mul(num, den_inv_x, den_inv_y);

        // 3. Verify that the proposed sum is the constructed point
        return (c_x == proposed_sum_x && c_y == proposed_sum_y);
    }
}
