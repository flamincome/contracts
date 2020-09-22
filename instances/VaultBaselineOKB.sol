// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "../implementations/vault/VaultBaseline.sol";

contract VaultBaselineOKB is VaultBaseline {
    constructor()
        public
        VaultBaseline(
            address(0x75231F58b43240C9718Dd58B4967c5114342a86c),
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
