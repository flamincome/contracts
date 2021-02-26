// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/vault/VaultX.sol";

contract VaultXWETH is VaultX {
    constructor(address _strategy)
        public
        VaultX(
            address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2), // https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
            _strategy
        )
    {}
}

