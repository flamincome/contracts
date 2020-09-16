// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyBaselineAmmonia.sol";

contract StrategyBaselineAmmoniaTUSD is StrategyBaselineAmmonia {
    constructor()
        public
        StrategyBaselineAmmonia(
            address(0x0000000000085d4780B73119b644AE5ecd22b376),
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
