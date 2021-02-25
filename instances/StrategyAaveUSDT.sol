// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyAave.sol";

contract StrategyAaveUSDT is StrategyAave {
    constructor()
        public
        StrategyAave(
            address(0xdAC17F958D2ee523a2206206994597C13D831ec7), // https://etherscan.io/address/0xdac17f958d2ee523a2206206994597c13d831ec7
            address(0x3Ed3B47Dd13EC9a98b44e6204A523E766B225811), // https://docs.aave.com/developers/getting-started/deployed-contracts
            address(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9)  // https://docs.aave.com/developers/getting-started/deployed-contracts
        )
    {}
}

