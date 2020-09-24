// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/normalizer/NormalizerMethane.sol";

contract NormalizerMethaneUni_WBTC_WETH is NormalizerMethane {
    constructor()
        public
        NormalizerMethane(address(0x743BC5cc8F52a84fF6e06E47Bc2af5324f5463D6))
    {}
}
