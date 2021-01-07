// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/Controller.sol";
import "../../interfaces/flamincome/Vault.sol";

import "./StrategyBaseline.sol";

contract StrategyBaselineAmmonia is StrategyBaseline {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    constructor(address _want)
        public
        StrategyBaseline(_want)
    {}

    function deposit() public override {}

    function withdraw(IERC20 _asset)
        external
        override
        returns (uint256 balance)
    {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    function withdraw(uint256 _amount) external virtual override {
        require(msg.sender == vaultX || msg.sender == vaultY, "!vault");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        _amount = Math.min(_balance, _amount);
        IERC20(want).safeTransfer(msg.sender, _amount);
    }

    function balanceOf() public override view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }
}
