// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FakeCoin is ERC20 {
    constructor()
        public
        ERC20(string("fakecoin"), string("FAKE"))
    {
        _mint(msg.sender, 1e20);
    }
}
