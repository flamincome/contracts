// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./Strategy.sol";
import "../../interfaces/external/WETH.sol";
import "../../interfaces/external/Aave.sol";

contract StrategyAave is Strategy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public atoken;
    address public lendingpool;

    constructor(address _want, address _atoken, address _lendingpool) public Strategy(_want) {
        atoken = _atoken;
        lendingpool = _lendingpool;
    }

    function update(address _newStratrgy) public override {
        require(msg.sender == governance, "!governance");
        withdraw(1e18); // withdraw 100%
        uint256 _balance = IERC20(want).balanceOf(address(this));
        IERC20(want).safeTransfer(_newStratrgy, _balance);
        IVaultX(vaultX).setStrategy(_newStratrgy);
        IVaultY(vaultY).setStrategy(_newStratrgy);
    }

    function deposit(uint256 _ne18) public override {
        require(msg.sender == governance, "!governance");
        uint256 _amount = IERC20(want).balanceOf(address(this)).mul(_ne18).div(1e18);
        IERC20(want).approve(lendingpool, _amount);
        ILendingPoolV2(lendingpool).deposit(want, _amount, address(this), 0);
    }

    function withdrawByAmount(uint256 _amount) internal {
        ILendingPoolV2(lendingpool).withdraw(want, _amount, address(this));
    }

    function withdraw(uint256 _ne18) public {
        require(msg.sender == governance, "!governance");
        uint256 _amount = IERC20(atoken).balanceOf(address(this)).mul(_ne18).div(1e18);
        ILendingPoolV2(lendingpool).withdraw(want, _amount, address(this));
    }

    function safeWithdraw(uint256 _amount) public {
        require(msg.sender == governance, "!governance");
        withdrawByAmount(_amount);
    }

    function withdraw(address _to, uint256 _amount) public override {
        require(msg.sender == vaultX || msg.sender == vaultY, "!vault");

        uint256 _balance = IERC20(want).balanceOf(address(this));

        if (_balance < _amount) {
            withdrawByAmount(_amount.sub(_balance));
            _amount = Math.min(IERC20(want).balanceOf(address(this)), _amount);
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
        uint atokenAmount = IERC20(atoken).balanceOf(address(this));
        return IERC20(want).balanceOf(address(this)).add(atokenAmount).sub(IERC20(vaultX).totalSupply());
    }

    // needs a payable function in order to receive ETH when redeem cETH.
    receive() external payable {}
}

