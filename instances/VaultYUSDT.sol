// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/vault/VaultY.sol";

contract VaultYUSDT is VaultY {
    constructor(address _strategy)
        public
        VaultY(
            address(0xdAC17F958D2ee523a2206206994597C13D831ec7), // https://etherscan.io/address/0xdac17f958d2ee523a2206206994597c13d831ec7
            _strategy
        )
    {}
}

