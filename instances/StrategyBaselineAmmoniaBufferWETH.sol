// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyBaselineAmmoniaBuffer.sol";

contract StrategyBaselineAmmoniaBufferWETH is StrategyBaselineAmmoniaBuffer {
    constructor(address _controller, address _xvault)
        public
        StrategyBaselineAmmoniaBuffer(
            address(0xE179198Fd42f5De1a04Ffd9a36D6DC428cEB13f7), // https://etherscan.io/address/0xe179198fd42f5de1a04ffd9a36d6dc428ceb13f7
            address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2), // https://etherscan.io/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
            _controller,
            _xvault
        )
    {}
}

