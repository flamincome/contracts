// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/strategy/StrategyBaselineAmmonia.sol";

contract StrategyBaselineAmmoniaOKB is StrategyBaselineAmmonia {
    constructor()
        public
        StrategyBaselineAmmonia(
            address(0x75231F58b43240C9718Dd58B4967c5114342a86c),
            address(0xDc03b4900Eff97d997f4B828ae0a45cd48C3b22d)
        )
    {}
}
