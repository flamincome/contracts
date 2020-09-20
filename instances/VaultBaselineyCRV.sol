// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "../implementations/vault/VaultBaseline.sol";

contract VaultBaselineyCRV is VaultBaseline {
    constructor()
        public
        VaultBaseline(
            address(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8),
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
