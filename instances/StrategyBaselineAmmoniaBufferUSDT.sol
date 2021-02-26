// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyBaselineAmmoniaBuffer.sol";

contract StrategyBaselineAmmoniaBufferUSDT is StrategyBaselineAmmoniaBuffer {
    constructor(address _controller, address _xvault)
        public
        StrategyBaselineAmmoniaBuffer(
            address(0x2205d2F559ef91580090011Aa4E0eF68Ec33da44), // https://etherscan.io/address/0x2205d2f559ef91580090011aa4e0ef68ec33da44
            address(0xdAC17F958D2ee523a2206206994597C13D831ec7), // https://etherscan.io/address/0xdac17f958d2ee523a2206206994597c13d831ec7
            _controller,
            _xvault
        )
    {}
}

