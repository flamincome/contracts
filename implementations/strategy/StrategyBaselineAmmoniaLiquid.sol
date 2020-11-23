// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/Controller.sol";
import "../../interfaces/flamincome/Vault.sol";

import "./StrategyBaseline.sol";

contract StrategyBaselineAmmoniaLiquid is StrategyBaseline {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public nwant;

    constructor(address _nwant, address _want, address _controller)
        public
        StrategyBaseline(_want, _controller)
    {
        nwant = _nwant;
    }

    function deposit() public override {}

    function liquid(uint256 amount) public {
        require(amount <= IERC20(nwant).balanceOf(msg.sender), "nwant not enough balance");
        require(amount <= balanceOf(want), "want not enough balance");

        IERC20(nwant).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(want).safeTransfer(msg.sender, amount);
    }

    function liquidAll() public {
        uint256 amount = IERC20(nwant).balanceOf(msg.sender);
        liquid(amount);
    }

    function withdraw(IERC20 _asset)
        external
        override
        returns (uint256 balance)
    {}

    function withdraw(uint256 _amount) external virtual override 
    {}

    function withdrawAll() external override returns (uint256 balance) 
    {}

    function balanceOf(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function balanceOf() public override view returns (uint256) {
        return balanceOf(want).add(balanceOf(nwant));
    }
}

