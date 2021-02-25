// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyAave.sol";

contract StrategyAaveUSDT is StrategyAave {
    constructor()
        public
        StrategyAave(
            address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2), // https://etherscan.io/address/0xdac17f958d2ee523a2206206994597c13d831ec7
            address(0x030bA81f1c18d280636F32af80b9AAd02Cf0854e), // https://docs.aave.com/developers/getting-started/deployed-contracts
            address(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9)  // https://docs.aave.com/developers/getting-started/deployed-contracts
        )
    {}
}

