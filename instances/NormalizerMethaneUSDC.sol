// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/normalizer/NormalizerMethane.sol";

contract NormalizerMethaneUSDC is NormalizerMethane {
    constructor()
        public
        NormalizerMethane(address(0x3f7E3d82bdDc28d3Eb04F0d0A51e9Fc82db581f0))
    {}
}
