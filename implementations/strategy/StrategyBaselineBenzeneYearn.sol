// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/Controller.sol";
import "../../interfaces/flamincome/Vault.sol";
import "../../interfaces/external/Curve.sol";
import "../../interfaces/external/YFI.sol";

import "./StrategyBaselineBenzene.sol";

contract StrategyBaselineBenzeneYearn is StrategyBaselineBenzene {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;


    constructor(address _y, address _controller)
        public
        StrategyBaselineBenzene(address(0x6B175474E89094C44Da98b954EedeAC495271d0F), _controller)
    {
        SetRecv(_y);
    }

    function DepositToken(uint256 _amount) internal override {
        IERC20(want).safeApprove(recv, 0);
        IERC20(want).safeApprove(recv, _amount);
        IYFIVault(recv).deposit(_amount);
    }

    function WithdrawToken(uint256 _amount) internal override {
        IYFIVault(recv).withdraw(_amount);
    }

    function GetPriceE18OfRecvInWant() public override view returns (uint256) {
        return IYFIVault(recv).getPricePerFullShare();
    }
}
