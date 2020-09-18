// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/vault/VaultBaseline.sol";

contract VaultBaselinesBTC is VaultBaseline {
    constructor()
        public
        VaultBaseline(
            address(0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6),
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
