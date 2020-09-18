// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/normalizer/NormalizerMethane.sol";

contract NormalizerMethanesBTC is NormalizerMethane {
    constructor()
        public
        NormalizerMethane(address(0x681D3261CC6d2A18b59f8B53219b96F06BcEeB69))
    {}
}
