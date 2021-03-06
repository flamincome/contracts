// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/vault/VaultBaseline.sol";

contract VaultBaselineaETH is VaultBaseline {
    constructor()
        public
        VaultBaseline(
            address(0x3a3A65aAb0dd2A17E3F1947bA16138cd37d08c04),
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
