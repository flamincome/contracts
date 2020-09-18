// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/normalizer/NormalizerMethane.sol";

contract NormalizerMethanerenBTC is NormalizerMethane {
    constructor()
        public
        NormalizerMethane(address(0xB0B3442b632175B0b7d9521291c51060722C4e8C))
    {}
}
