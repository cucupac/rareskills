// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {PreCompiles} from "./libraries/PreCompiles.sol";

contract RationalMath {
    struct ECPoint {
        uint256 x;
        uint256 y;
    }

    /// @dev claim: “I know two rational numbers that add up to num/den”
    function rationalAdd(ECPoint calldata A, ECPoint calldata B, uint256 num, uint256 den) public view returns (bool) {
        // construct N
        (uint256 N_x, uint256 N_y) = PreCompiles.mul(num, 1, 2);

        // add points A and B to get point C
        (uint256 C_x, uint256 C_y) = PreCompiles.add(A.x, A.y, B.x, B.y);

        // multiply C by den to get point T
        (uint256 T_x, uint256 T_y) = PreCompiles.mul(den, C_x, C_y);

        // check equivalence
        return (N_x == T_x && N_y == T_y);
    }
}
