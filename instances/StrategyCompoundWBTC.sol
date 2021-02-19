// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyWETHCompound.sol";

contract StrategyCompoundWETH is StrategyWETHCompound {
    constructor()
        public
        StrategyWETHCompound(
            address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599), // https://etherscan.io/address/0x2260fac5e5542a773aa44fbcfedf7c193bc2c599
            address(0xc11b1268c1a384e55c48c2391d8d480264a3a7f4)  // https://compound.finance/docs#networks
        )
    {}
}

