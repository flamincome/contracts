// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/normalizer/NormalizerMethane.sol";

contract NormalizerMethaneUSDT is NormalizerMethane {
    constructor()
        public
        NormalizerMethane(address(0x54bE9254ADf8D5c8867a91E44f44c27f0c88e88A))
    {}
}
