// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyBaselineBenzeneCurveUSD.sol";

contract StrategyBaselineBenzeneCurveUSDUSDT is StrategyBaselineBenzeneCurveUSD {
    constructor()
        public
        StrategyBaselineBenzeneCurveUSD(
            2,
            address(0xc1624A9b9bf3b339Ce3b03F8ffbF79e4041a7287)
        )
    {}
}
