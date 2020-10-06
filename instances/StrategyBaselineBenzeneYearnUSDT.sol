// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyBaselineBenzeneYearn.sol";

contract StrategyBaselineBenzeneYearnUSDT is StrategyBaselineBenzeneYearn {
    constructor()
        public
        StrategyBaselineBenzeneYearn(
            address(0xa1787206d5b1bE0f432C4c4f96Dc4D1257A1Dd14),
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
