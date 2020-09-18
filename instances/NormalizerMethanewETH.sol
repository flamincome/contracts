// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/normalizer/NormalizerMethane.sol";

contract NormalizerMethanewETH is NormalizerMethane {
    constructor()
        public
        NormalizerMethane(address(0x1E9DC5d843731D333544e63B2B2082D21EF78ed3))
    {}
}
