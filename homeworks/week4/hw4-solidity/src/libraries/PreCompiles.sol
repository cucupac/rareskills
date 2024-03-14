// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

library PreCompiles {
    function modExp(uint256 b, uint256 e, uint256 m) internal view returns (uint256 result) {
        bytes memory input = abi.encodePacked(uint256(0x20), uint256(0x20), uint256(0x20), b, e, m);
        (bool ok, bytes memory output) = address(0x05).staticcall(input);
        require(ok, "modExp failed");
        result = abi.decode(output, (uint256));
    }

    function add(uint256 x1, uint256 y1, uint256 x2, uint256 y2) public view returns (uint256 x, uint256 y) {
        (bool ok, bytes memory result) = address(6).staticcall(abi.encode(x1, y1, x2, y2));
        require(ok, "add failed");
        (x, y) = abi.decode(result, (uint256, uint256));
    }

    function mul(uint256 scalar, uint256 x1, uint256 y1) public view returns (uint256 x, uint256 y) {
        (bool ok, bytes memory result) = address(7).staticcall(abi.encode(x1, y1, scalar));
        require(ok, "mul failed");
        (x, y) = abi.decode(result, (uint256, uint256));
    }

    function pairing(uint256[24] memory input) public view returns (bool) {
        assembly {
            let success := staticcall(gas(), 0x08, input, 0x300, input, 0x20)
            if success { return(input, 0x20) }
        }
        revert("pairing failed");
    }
}
