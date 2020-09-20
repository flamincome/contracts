// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyBaselineBenzeneCurveUSD.sol";

contract StrategyBaselineBenzeneCurveUSDDAI is StrategyBaselineBenzeneCurveUSD {
    constructor()
        public
        StrategyBaselineBenzeneCurveUSD(
            0,
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
