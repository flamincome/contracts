// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyBaselineBenzeneYearn.sol";

contract StrategyBaselineBenzeneYearnUSDT is StrategyBaselineBenzeneYearn {
    constructor()
        public
        StrategyBaselineBenzeneYearn(
            address(0xa1787206d5b1bE0f432C4c4f96Dc4D1257A1Dd14),
            address(0xc1624A9b9bf3b339Ce3b03F8ffbF79e4041a7287)
        )
    {}
}
