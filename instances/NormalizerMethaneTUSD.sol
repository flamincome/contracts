// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/normalizer/NormalizerMethane.sol";

contract NormalizerMethaneTUSD is NormalizerMethane {
    constructor()
        public
        NormalizerMethane(address(0xa322AEa77769666453377CC697fbE4C6390b9942))
    {}
}
