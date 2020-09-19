// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/Controller.sol";
import "../../interfaces/flamincome/Vault.sol";
import "../../interfaces/external/DForce.sol";

import "./StrategyBaselineBenzene.sol";

contract StrategyBaselineBenzeneYearn is StrategyBaselineBenzene {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;


    constructor(address _d, address _controller)
        public
        StrategyBaselineBenzene(IDERC20(_d).token(), _controller)
    {
        SetRecv(_d);
    }

    function DepositToken(uint256 _amount) internal override {
        IERC20(want).safeApprove(recv, 0);
        IERC20(want).safeApprove(recv, _amount);
        IDERC20(recv).mint(address(this), _amount);
    }

    function WithdrawToken(uint256 _amount) internal override {
        IDERC20(recv).redeem(address(this), _amount);
    }

    function GetPriceE18OfRecvInWant() public override view returns (uint256) {
        return IDERC20(recv).getExchangeRate();
    }
}
