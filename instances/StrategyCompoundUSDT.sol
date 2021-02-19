// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyWETHCompound.sol";

contract StrategyCompoundWETH is StrategyWETHCompound {
    constructor()
        public
        StrategyWETHCompound(
            address(0xdAC17F958D2ee523a2206206994597C13D831ec7), // https://etherscan.io/address/0xdac17f958d2ee523a2206206994597c13d831ec7
            address(0xf650c3d88d12db855b8bf7d11be6c55a4e07dcc9)  // https://compound.finance/docs#networks
        )
    {}
}

