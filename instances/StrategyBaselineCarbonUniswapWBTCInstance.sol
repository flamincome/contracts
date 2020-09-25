// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyBaselineCarbonUniswapWBTC.sol";

contract StrategyBaselineCarbonUniswapWBTCInstance is StrategyBaselineCarbonUniswapWBTC {
    constructor()
        public
        StrategyBaselineCarbonUniswapWBTC(
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
