// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/vault/VaultBaseline.sol";

contract VaultBaselinerenBTC is VaultBaseline {
    constructor()
        public
        VaultBaseline(
            address(0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D),
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
