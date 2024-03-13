// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library PreCompiles {
    function modExp(uint256 b, uint256 e, uint256 m) internal view returns (uint256 result) {
        bytes memory input = abi.encodePacked(uint256(0x20), uint256(0x20), uint256(0x20), b, e, m);
        (bool ok, bytes memory output) = address(0x05).staticcall(input);
        require(ok, "modExp failed");
        result = abi.decode(output, (uint256));
    }

    function add(uint256 x1, uint256 y1, uint256 x2, uint256 y2) internal view returns (uint256 x, uint256 y) {
        (bool ok, bytes memory result) = address(6).staticcall(abi.encode(x1, y1, x2, y2));
        require(ok, "add failed");
        (x, y) = abi.decode(result, (uint256, uint256));
    }

    function mul(uint256 scalar, uint256 x1, uint256 y1) internal view returns (uint256 x, uint256 y) {
        (bool ok, bytes memory result) = address(7).staticcall(abi.encode(x1, y1, scalar));
        require(ok, "mul failed");
        (x, y) = abi.decode(result, (uint256, uint256));
    }
}

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
