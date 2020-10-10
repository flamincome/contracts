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

contract StrategyBaselineBenzeneCurveUSD3Pool is StrategyBaselineBenzene {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant curve = address(
        0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7
    );
    int128 public index;

    constructor(uint256 _index, address _controller)
        public
        StrategyBaselineBenzene(ICurveFi3Pool(curve).coins(_index), _controller)
    {
        index = int128(_index);
        SetRecv(address(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490));
    }

    function DepositToken(uint256 _amount) internal override {
        IERC20(want).safeApprove(curve, 0);
        IERC20(want).safeApprove(curve, _amount);
        uint256[3] memory vec = [
            uint256(0),
            uint256(0),
            uint256(0)
        ];
        vec[uint256(index)] = _amount;
        ICurveFi3Pool(curve).add_liquidity(vec, 0);
    }

    function WithdrawToken(uint256 _amount) internal override {
        IERC20(recv).safeApprove(curve, 0);
        IERC20(recv).safeApprove(curve, _amount);
        uint256[3] memory vec = [
            uint256(0),
            uint256(0),
            uint256(0)
        ];
        ICurveFi3Pool(curve).remove_liquidity(_amount, vec);

        for (int128 i = 0; i < 3; i++) {
            if (i == index) {
                continue;
            }
            address erc20 = ICurveFi3Pool(curve).coins(uint256(i));
            uint256 _bal = IERC20(erc20).balanceOf(address(this));
            if (_bal > 0) {
                IERC20(erc20).safeApprove(curve, 0);
                IERC20(erc20).safeApprove(curve, _bal);
                ICurveFi3Pool(curve).exchange(i, index, _bal, 0);
            }
        }
    }

    function GetPriceE18OfRecvInWant() public override view returns (uint256) {
        if (index == 1 || index == 2) {
            return
                ICurveFi3Pool(curve).get_virtual_price().mul(1e6);
        }
        return
            ICurveFi3Pool(curve).get_virtual_price().mul(1e18);
    }
}
