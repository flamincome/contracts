// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/Strategy_YFI_wETH.sol";

contract Strategy_YFI_wETHInstrance is Strategy_YFI_wETH {
    constructor()
        public
        Strategy_YFI_wETH(address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d))
    {}
}
