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

    constructor(address _want, address _controller)
        public
        StrategyBaseline(_want, _controller)
    {}

    function deposit() public virtual override {}

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
        require(msg.sender == controller, "!controller");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        _amount = Math.min(_balance, _amount);
        address vault = Controller(controller).vaults(address(want));
        require(vault != address(0), "!vault");
        IERC20(want).safeTransfer(vault, _amount);
    }

    function withdrawAll() external override returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        balance = IERC20(want).balanceOf(address(this));
        address vault = Controller(controller).vaults(address(want));
        require(vault != address(0), "!vault");
        IERC20(want).safeTransfer(vault, balance);
    }

    function balanceOf() public virtual override view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }
}
