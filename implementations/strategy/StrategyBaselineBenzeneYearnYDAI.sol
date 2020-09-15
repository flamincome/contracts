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

contract StrategyBaselineBenzeneYearnYDAI is StrategyBaselineBenzene {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant y = address(
        0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01
    );

    constructor(address _controller)
        public
        StrategyBaselineBenzene(
            address(0x6B175474E89094C44Da98b954EedeAC495271d0F),
            _controller
        )
    {}

    function DepositToken(uint256 _amount) public override {
        IERC20(want).safeApprove(y, 0);
        IERC20(want).safeApprove(y, _amount);
        IYFIVault(y).deposit(_amount);
    }

    // function WithdrawToken(uint256 _amount) public override {
    //     IERC20(recv).safeApprove(curve, 0);
    //     IERC20(recv).safeApprove(curve, _amount);
    //     uint256[4] memory vec = [
    //         uint256(0),
    //         uint256(0),
    //         uint256(0),
    //         uint256(0)
    //     ];
    //     ICurveFi(curve).remove_liquidity(_amount, vec);

    //     for (int128 i = 0; i < 4; i++) {
    //         if (i == index) {
    //             continue;
    //         }
    //         address erc20 = ICurveFi(curve).coins(i);
    //         uint256 _bal = IERC20(erc20).balanceOf(address(this));
    //         if (_bal > 0) {
    //             IERC20(erc20).safeApprove(curve, 0);
    //             IERC20(erc20).safeApprove(curve, _bal);
    //             ICurveFi(curve).exchange(i, index, _bal, 0);
    //         }
    //     }
    // }

    // function GetRecv() public override view returns (address) {
    //     return address(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8);
    // }

    // function GetPriceE18OfRecvInWant() public override view returns (uint256) {
    //     return
    //         ICurveFi(curve).get_virtual_price().mul(1e18).div(
    //             IYFIVault(want).getPricePerFullShare()
    //         );
    // }
}
