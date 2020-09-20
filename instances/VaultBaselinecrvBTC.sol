// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "../implementations/vault/VaultBaseline.sol";

contract VaultBaselinecrvBTC is VaultBaseline {
    constructor()
        public
        VaultBaseline(
            address(0x075b1bb99792c9E1041bA13afEf80C91a1e70fB3),
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
