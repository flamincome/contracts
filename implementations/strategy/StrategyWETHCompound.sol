// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./Strategy.sol";
import "../../interfaces/external/WETH.sol";
import "../../interfaces/external/Compound.sol";

contract StrategyWETHCompound is Strategy_New {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public ceth;

    constructor(address _want, address _ceth) public Strategy_New(_want) {
        ceth = _ceth;
    }

    function deposit(uint256 _amount) public override {
        require(msg.sender == governance, "!governance");
        // WETH => ETH
        IWETH(want).withdraw(_amount);
        CETH cToken = CETH(ceth);
        cToken.mint{value: _amount}();
    }

    function withdraw(uint256 _amount) internal {
        CETH cToken  = CETH(ceth);
        uint256 _redeemResult = cToken.redeemUnderlying(_amount);
        // https://compound.finance/developers/ctokens#ctoken-error-codes
        require(_redeemResult == 0, "redeemResult error");

        IWETH(want).deposit{value: address(this).balance}();
    }

    function safeWithdraw(uint256 _amount) public {
        require(msg.sender == governance, "!governance");
        withdraw(_amount);
    }

    function withdraw(address _to, uint256 _amount) public override {
        require(msg.sender == vaultX || msg.sender == vaultY, "!vault");

        uint256 _balance = underlyingAmount();
        _amount = Math.min(_balance, _amount);
        withdraw(_amount);
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
        return cToken.balanceOf(address(this)).mul(cToken.exchangeRateStored()).div(1e18);
    }

    // needs a payable function in order to receive ETH when redeem cETH.
    receive() external payable {}
}

