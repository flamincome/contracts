// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "../implementations/controller/ControllerBaseline.sol";

contract ControllerBaselineSingleton is ControllerBaseline {
    constructor()
        public
        ControllerBaseline(address(0x7251cDf96fcBF566A699b79A8A3d0E899310e958))
    {}
}
