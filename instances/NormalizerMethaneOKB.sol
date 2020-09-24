// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/normalizer/NormalizerMethane.sol";

contract NormalizerMethaneOKB is NormalizerMethane {
    constructor()
        public
        NormalizerMethane(address(0x272C8dF3E8068952606046c1389fc1e2320FCCfd))
    {}
}
