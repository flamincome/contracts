// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/Controller.sol";
import "../../interfaces/flamincome/Vault.sol";
import "../../interfaces/external/Swerve.sol";
import "../../interfaces/external/YFI.sol";

import "./StrategyBaselineBenzene.sol";

contract StrategyBaselineBenzeneSwerveUSD is StrategyBaselineBenzene {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant swerve = address(
        0xa746c67eB7915Fa832a4C2076D403D4B68085431
    );
    int128 public index;

    constructor(int128 _index, address _controller)
        public
        StrategyBaselineBenzene(ISwerveFi(swerve).coins(_index), _controller)
    {
        index = _index;
        SetRecv(address(0x77C6E4a580c0dCE4E5c7a17d0bc077188a83A059));
    }

    function DepositToken(uint256 _amount) internal override {
        IERC20(want).safeApprove(swerve, 0);
        IERC20(want).safeApprove(swerve, _amount);
        uint256[4] memory vec = [
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0)
        ];
        vec[uint256(index)] = _amount;
        ISwerveFi(swerve).add_liquidity(vec, 0);
    }

    function WithdrawToken(uint256 _amount) internal override {
        IERC20(recv).safeApprove(swerve, 0);
        IERC20(recv).safeApprove(swerve, _amount);
        ISwerveFi(swerve).remove_liquidity_one_coin(_amount, index, 0);
    }

    function GetPriceE18OfRecvInWant() public override view returns (uint256) {
        uint256 _frecv = IERC20(frecv).balanceOf(address(this));
        uint256 _recv = IERC20(recv).balanceOf(address(this));
        if (_frecv > 0) {
            _frecv = Vault(frecv).priceE18().mul(_frecv).div(1e18);
            _recv = _recv.add(_frecv);
        }
        return ISwerveFi(swerve).calc_withdraw_one_coin(_recv, index);
    }
}
