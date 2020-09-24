// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "../implementations/vault/VaultBaseline.sol";

contract VaultBaselineUni_WBTC_WETH is VaultBaseline {
    constructor()
        public
        VaultBaseline(
            address(0xBb2b8038a1640196FbE3e38816F3e67Cba72D940),
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
