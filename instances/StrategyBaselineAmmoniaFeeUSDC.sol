// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyBaselineAmmoniaFee.sol";

contract StrategyBaselineAmmoniaFeeUSDC is StrategyBaselineAmmoniaFee {
    constructor()
        public
        StrategyBaselineAmmoniaFee(
            address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48),
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
