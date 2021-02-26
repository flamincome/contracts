// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyBaselineAmmoniaBuffer.sol";

contract StrategyBaselineAmmoniaBufferWBTC is StrategyBaselineAmmoniaBuffer {
    constructor(address _controller, address _xvault)
        public
        StrategyBaselineAmmoniaBuffer(
            address(0xbB44B36e588445D7DA61A1e2e426664d03D40888), // https://etherscan.io/address/0xbb44b36e588445d7da61a1e2e426664d03d40888
            address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599), // https://etherscan.io/address/0x2260fac5e5542a773aa44fbcfedf7c193bc2c599
            _controller,
            _xvault
        )
    {}
}

