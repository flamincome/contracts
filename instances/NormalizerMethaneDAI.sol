// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/normalizer/NormalizerMethane.sol";

contract NormalizerMethaneDAI is NormalizerMethane {
    constructor()
        public
        NormalizerMethane(address(0x163D457fA8247f1A9279B9fa8eF513de116e4327))
    {}
}
