// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/Strategy_YFI_DForceUSDT.sol";

contract Strategy_YFI_DForceUSDTInstance is Strategy_YFI_DForceUSDT {
    constructor()
        public
        Strategy_YFI_DForceUSDT(address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d))
    {}
}
