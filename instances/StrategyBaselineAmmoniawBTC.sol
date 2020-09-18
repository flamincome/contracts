// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyBaselineAmmonia.sol";

contract StrategyBaselineAmmoniawBTC is StrategyBaselineAmmonia {
    constructor()
        public
        StrategyBaselineAmmonia(
            address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599),
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
