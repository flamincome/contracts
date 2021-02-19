// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./Strategy.sol";
import "../../interfaces/external/Compound.sol";

contract StrategyERC20Compound is Strategy_New {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public cerc20;

    constructor(address _want, address _cerc20) public Strategy_New(_want) {
        cerc20 = _cerc20;
    }

    function deposit(uint256 _amount) public override {
        require(msg.sender == governance, "!governance");
        IERC20(want).approve(cerc20, _amount);
        CERC20 cToken = CERC20(cerc20);
        cToken.mint(_amount);
    }

    function withdraw(uint256 _amount) internal {
        CERC20 cToken  = CERC20(cerc20);
        uint256 _redeemResult = cToken.redeemUnderlying(_amount);
        require(_redeemResult == 0, "redeemResult error");

        IWETH(want).deposit{value: address(this).balance}();
    }

    function withdrawByCToken(uint256 _amount) public {
        require(msg.sender == governance, "!governance");
        CERC20 cToken = CERC20(ceth);
        uint256 _redeemResult = cToken.redeem(_amount);
        require(_redeemResult == 0, "redeemResult error");
    }

    function safeWithdraw(uint256 _amount) public {
        require(msg.sender == governance, "!governance");
        withdraw(_amount);
    }

    function withdraw(address _to, uint256 _amount) public override {
        require(msg.sender == vaultX || msg.sender == vaultY, "!vault");

        uint256 _balance = IERC20(want).balanceOf(address(this));

        if (_balance < _amount) {
            withdraw(_amount.sub(_balance));
        }

        if (msg.sender == vaultX) {
            uint256 _fee = _amount.mul(feexe18).div(1e18);
            IERC20(want).safeTransfer(governance, _fee);
            IERC20(want).safeTransfer(_to, _amount.sub(_fee));
        }
        else if (msg.sender == vaultY) {
            uint256 _fee = _amount.mul(feeye18).div(1e18);
            IERC20(want).safeTransfer(governance, _fee);
            IERC20(want).safeTransfer(_to, _amount.sub(_fee));
        }
    }

    function balanceOfY() public view override returns (uint256) {
        return IERC20(want).balanceOf(address(this)).add(underlyingAmount()).sub(IERC20(vaultX).totalSupply());
    }

    function underlyingAmount() public view returns(uint) {
        CETH cToken  = CETH(ceth);
        // TODO: wbtc is 8 decimals, need to make sure the (/1e18) part is good enought
        return cToken.balanceOf(address(this)).mul(cToken.exchangeRateStored()).div(1e18);
    }
}
