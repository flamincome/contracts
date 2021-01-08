// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./Strategy.sol";

contract StrategyAmmonia is Strategy {
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
        require(msg.sender == vaultX || msg.sender == vaultY, "!vault");
        require(want != address(_asset), "want");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(msg.sender, balance);
    }

    function withdraw(address _to, uint256 _amount) external virtual override {
        require(msg.sender == vaultX || msg.sender == vaultY, "!vault");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        _amount = Math.min(_balance, _amount);
        IERC20(want).safeTransfer(_to, _amount);
    }

    function update(address _newStratrgy) external override {
        require(msg.sender == governance, "!governance");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        IERC20(want).safeTransfer(_newStratrgy, _balance);
        VaultBaselineX(vaultX).setStrategy(_newStratrgy);
        VaultBaselineY(vaultY).setStrategy(_newStratrgy);
    }

    function balanceOf() public override view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOfY() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this)).sub(IERC20(vaultX).totalSupply());
    }
}
