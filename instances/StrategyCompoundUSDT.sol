// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyERC20Compound.sol";

contract StrategyCompoundUSDT is StrategyERC20Compound {
    constructor()
        public
        StrategyERC20Compound(
            address(0xdAC17F958D2ee523a2206206994597C13D831ec7), // https://etherscan.io/address/0xdac17f958d2ee523a2206206994597c13d831ec7
            address(0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9), // https://compound.finance/docs#networks
            address(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B), // https://compound.finance/docs#networks
            address(0xc00e94Cb662C3520282E6f5717214004A7f26888), // https://compound.finance/docs#networks
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)  // https://etherscan.io/address/0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        )
    {}
}

