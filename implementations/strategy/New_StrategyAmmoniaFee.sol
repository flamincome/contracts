// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/Controller.sol";
import "../../interfaces/flamincome/Vault.sol";

import "./StrategyBaselineAmmonia.sol";

contract StrategyBaselineAmmoniaFee is StrategyBaselineAmmonia {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    uint256 public feen = 5e15;
    uint256 public constant feed = 1e18;

    constructor(address _want, address _controller)
        public
        StrategyBaselineAmmonia(_want, _controller)
    {}

    function withdraw(address _to, uint256 _amount) external override {
        require(msg.sender == vaultX || msg.sender == vaultY, "!vault");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        _amount = Math.min(_balance, _amount);
        uint256 _fee = _amount.mul(feen).div(feed);
        IERC20(want).safeTransfer(governance, _fee);
        IERC20(want).safeTransfer(_to, _amount.sub(_fee));
    }

    function setFeeN(uint256 _feen) external {
        require(msg.sender == governance, "!governance");
        feen = _feen;
    }
}
