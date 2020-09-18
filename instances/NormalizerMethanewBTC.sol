// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/normalizer/NormalizerMethane.sol";

contract NormalizerMethanewBTC is NormalizerMethane {
    constructor()
        public
        NormalizerMethane(address(0x1a389c381a8242B7acFf0eB989173Cd5d0EFc3e3))
    {}
}
