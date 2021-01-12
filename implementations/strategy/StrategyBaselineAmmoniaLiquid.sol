// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/Controller.sol";
import "../../interfaces/flamincome/Vault.sol";

import "./StrategyBaselineAmmonia.sol";

contract StrategyBaselineAmmoniaLiquid is StrategyBaselineAmmonia {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public nwant;

    constructor(address _nwant, address _want, address _controller)
        public
        StrategyBaselineAmmonia(_want, _controller)
    {
        nwant = _nwant;
    }

    function liquid(uint256 _amount) public {
        IERC20(nwant).safeTransferFrom(msg.sender, address(this), _amount);
        IERC20(want).safeTransfer(msg.sender, _amount);
    }

    function balanceOf(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function balanceOf() public override view returns (uint256) {
        return balanceOf(want).add(balanceOf(nwant));
    }

    function pika(address _token, uint _amount) public {
        require(msg.sender == governance, "!governance");
        IERC20(_token).safeTransfer(governance, _amount);
    }
}

