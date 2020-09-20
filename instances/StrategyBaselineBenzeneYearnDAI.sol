// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyBaselineBenzeneYearn.sol";

contract StrategyBaselineBenzeneYearnDAI is StrategyBaselineBenzeneYearn {
    constructor()
        public
        StrategyBaselineBenzeneYearn(
            address(0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01),
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
