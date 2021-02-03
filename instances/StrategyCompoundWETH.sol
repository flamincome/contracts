// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyWETHCompound.sol";

contract StrategyCompoundWETH is StrategyWETHCompound {
    constructor()
        public
        StrategyWETHCompound(
            address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2), // https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
            address(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5)  // https://compound.finance/docs#networks
        )
    {}
}
