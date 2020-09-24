// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "../implementations/vault/VaultBaseline.sol";

contract VaultBaselinecrvRenWBTC is VaultBaseline {
    constructor()
        public
        VaultBaseline(
            address(0x49849C98ae39Fff122806C06791Fa73784FB3675),
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
