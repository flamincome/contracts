// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyWETHCompound.sol";

contract StrategyCreamWETH is StrategyWETHCompound {
    constructor()
        public
        StrategyWETHCompound(
            address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2), // https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
            address(0xD06527D5e56A3495252A528C4987003b712860eE), // https://etherscan.io/address/0xD06527D5e56A3495252A528C4987003b712860eE
            address(0x3d5BC3c8d13dcB8bF317092d84783c2697AE9258), // https://etherscan.io/address/0x3d5BC3c8d13dcB8bF317092d84783c2697AE9258
            address(0x2ba592F78dB6436527729929AAf6c908497cB200), // https://etherscan.io/address/0x2ba592F78dB6436527729929AAf6c908497cB200
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)  // https://etherscan.io/address/0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        )
    {}
}

