// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyAave.sol";

contract StrategyAaveWBTC is StrategyAave {
    constructor()
        public
        StrategyAave(
            address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599), // https://etherscan.io/address/0xdac17f958d2ee523a2206206994597c13d831ec7
            address(0x9ff58f4fFB29fA2266Ab25e75e2A8b3503311656), // https://docs.aave.com/developers/getting-started/deployed-contracts
            address(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9)  // https://docs.aave.com/developers/getting-started/deployed-contracts
        )
    {}
}

