// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyERC20Compound.sol";

contract StrategyCompoundWBTC is StrategyERC20Compound {
    constructor()
        public
        StrategyERC20Compound(
            address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599), // https://etherscan.io/address/0x2260fac5e5542a773aa44fbcfedf7c193bc2c599
            address(0xC11b1268C1A384e55C48c2391d8d480264A3A7F4)  // https://compound.finance/docs#networks
        )
    {}
}

