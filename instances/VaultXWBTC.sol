// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/vault/VaultX.sol";

contract VaultXWBTC is VaultX {
    constructor(address _strategy)
        public
        VaultX(
            address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599), // https://etherscan.io/address/0x2260fac5e5542a773aa44fbcfedf7c193bc2c599
            _strategy
        )
    {}
}

