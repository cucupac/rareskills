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
    struct ECPoint {
        uint256 x;
        uint256 y;
    }

    function rationalAdd(ECPoint calldata A, ECPoint calldata B, uint256 num, uint256 den)
        public
        view
        returns (bool verified)
    {
        // construct N
        (uint256 N_x, uint256 N_y) = PreCompiles.mul(num, 1, 2);

        // add points A and B to get point C
        (uint256 C_x, uint256 C_y) = PreCompiles.add(A.x, A.y, B.x, B.y);

        // multiply C by den to get point T
        (uint256 T_x, uint256 T_y) = PreCompiles.mul(den, C_x, C_y);

        // check equivalence
        if (N_x == T_x && N_y == T_y) {
            verified = true;
        }
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
