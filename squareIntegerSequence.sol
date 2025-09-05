// SPDX-License-Identifier: MIT
/// Git repo at https://github.com/bestape/squareIntegerRatio
pragma solidity ^0.8.20;

/// @title AMM Approximation via Integer Recurrence using int256 Q64.64
/// @notice Approximates 1 + k * sqrt(m) with flexible 0-7 tolerance scale
contract SqrtIntegerRatio {

    int256 private constant ONE_Q64_64 = int256(1) << 64;
    uint256 private constant MAX_ITER = 2000;
    uint256 private constant SCALE = 1e18; // for decimal formatting

    /// @notice Compute recurrence approximation with a tolerance level 0-7
    function compute(uint256 k, uint256 m, uint8 level)
        external
        pure
        returns (
            uint256 n,
            string memory a_n_str,
            string memory a_n_minus_1_str,
            string memory result_str
        )
    {
        require(k > 0 && m > 0, "k,m > 0 required");
        require(level <= 7, "level must be 0-7");

        int256 tol = tolFromLevel(level);

        int256 prev2 = ONE_Q64_64; // a0
        int256 sqrtM = sqrtQ64_64(toQ64_64(m));
        int256 kSqrtM = mulQ64_64(toQ64_64(k), sqrtM);
        int256 prev1 = addQ64_64(ONE_Q64_64, kSqrtM);

        uint256 coeffUnsigned = k * k * m - 1;
        int256 coeff = toQ64_64(toInt256Safe(coeffUnsigned));

        int256 ratio = divQ64_64(prev1, prev2);
        n = 1;

        while (true) {
            n++;
            int256 curr = addQ64_64(mulQ64_64(2 * ONE_Q64_64, prev1), mulQ64_64(coeff, prev2));
            int256 newRatio = divQ64_64(curr, prev1);
            int256 diff = absQ64(newRatio - ratio);

            if (diff <= tol || n >= MAX_ITER) {
                prev2 = prev1;
                prev1 = curr;
                break;
            }

            prev2 = prev1;
            prev1 = curr;
            ratio = newRatio;
        }

        int256 ratioFinal = divQ64_64(prev1, prev2);

        a_n_str = formatQ64_64(prev1);
        a_n_minus_1_str = formatQ64_64(prev2);
        result_str = formatQ64_64(ratioFinal);
    }

    /// @notice Map 0-7 scale to Q64.64 tolerance
    function tolFromLevel(uint8 level) internal pure returns (int256) {
        if (level == 0) return int256(ONE_Q64_64 / 1);      // ~100%
        if (level == 1) return int256(ONE_Q64_64 / 10);     // ~10%
        if (level == 2) return int256(ONE_Q64_64 / 100);    // ~1%
        if (level == 3) return int256(ONE_Q64_64 / 10000);  // ~0.01%
        if (level == 4) return int256(ONE_Q64_64 / 1000000);// ~0.0001%
        if (level == 5) return int256(1 << 10);             // near full Q64.64
        if (level == 6) return int256(1 << 5);              // seed for Newton
        if (level == 7) return int256(1);                   // full Newton requirement
        revert("level must be 0-7");
    }

    // --- Helpers for decimal formatting ---
    function formatQ64_64(int256 value) internal pure returns (string memory) {
        uint256 scaled = uint256(value >= 0 ? value : -value);
        uint256 integerPart = scaled >> 64;
        uint256 fractionalPart = (scaled & 0xFFFFFFFFFFFFFFFF) * SCALE >> 64;
        string memory sign = value < 0 ? "-" : "";

        if (fractionalPart == 0) {
            return string(abi.encodePacked(sign, uint2str(integerPart)));
        } else {
            return string(
                abi.encodePacked(sign, uint2str(integerPart), ".", padFraction(fractionalPart))
            );
        }
    }

    function padFraction(uint256 x) internal pure returns (string memory) {
        if (x == 0) return "0";

        uint256 temp = x;
        uint256 digits = 0;
        while (temp > 0) {
            digits++;
            temp /= 10;
        }

        bytes memory str = new bytes(digits);
        temp = x;
        for (uint256 i = digits; i > 0; i--) {
            str[i - 1] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }

        return string(str);
    }

    function uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) return "0";
        uint256 j = _i;
        uint256 length;
        while (j != 0) { length++; j /= 10; }
        bytes memory bstr = new bytes(length);
        j = _i;
        while (j != 0) {
            bstr[--length] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bstr);
    }

    function toInt256Safe(uint256 x) internal pure returns (int256) {
        require(x <= uint256(type(int256).max), "overflow converting uint256 to int256");
        return int256(x);
    }

    // --- Q64.64 helpers ---
    function toQ64_64(uint256 x) internal pure returns (int256) { return int256(x) << 64; }
    function toQ64_64(int256 x) internal pure returns (int256) { return x << 64; }
    function divQ64_64(int256 x, int256 y) internal pure returns (int256) { return (x << 64) / y; }
    function mulQ64_64(int256 x, int256 y) internal pure returns (int256) { return (x * y) >> 64; }
    function addQ64_64(int256 x, int256 y) internal pure returns (int256) { return x + y; }
    function absQ64(int256 x) internal pure returns (int256) { return x >= 0 ? x : -x; }

    function sqrtQ64_64(int256 x) internal pure returns (int256) {
        require(x >= 0, "sqrt negative");
        uint256 raw = uint256(x >> 64);
        return int256(sqrt(raw) << 64);
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) { z = x; x = (y / x + x) / 2; }
        } else if (y != 0) { z = 1; }
    }
}
