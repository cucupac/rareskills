// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {PreCompiles} from "./libraries/PreCompiles.sol";

contract MatrixMultiplication {
    struct ECPoint {
        uint256 x;
        uint256 y;
    }

    // errors
    error InvalidMatrix();

    function matmul(
        uint256[] calldata matrix,
        uint256 n, // n x n matrix
        ECPoint[] calldata s, // n points
        ECPoint[] calldata o // n points
    ) public view returns (bool) {
        if (matrix.length != n * n || s.length != n || o.length != n) revert InvalidMatrix();

        for (uint256 row; row < n; row++) {
            // reset result point
            ECPoint memory resultPoint = ECPoint({x: 0, y: 0});

            // loop through columns for this row
            for (uint256 col; col < n; col++) {
                // extract matrix elem
                uint256 elem = matrix[row * n + col];

                // extract operand point
                ECPoint memory sPoint = s[col];

                // obtain product point
                (uint256 p_x, uint256 p_y) = PreCompiles.mul(elem, sPoint.x, sPoint.y);

                // add product point to result point
                (resultPoint.x, resultPoint.y) = PreCompiles.add(resultPoint.x, resultPoint.y, p_x, p_y);
            }

            // now that inner for loor has run, check point equality
            if (o[row].x != resultPoint.x || o[row].y != resultPoint.y) {
                return false;
            }
        }
        return true;
    }
}
