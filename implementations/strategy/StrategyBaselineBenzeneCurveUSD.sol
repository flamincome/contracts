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

contract StrategyBaselineBenzeneCurveUSD is StrategyBaselineBenzene {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant curve = address(
        0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51
    );
    int128 public index;

    constructor(int128 _index, address _controller)
        public
        StrategyBaselineBenzene(ICurveFi(curve).coins(_index), _controller)
    {
        index = _index;
        SetRecv(address(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8));
    }

    function DepositToken(uint256 _amount) internal override {
        // uint256 _amount = IERC20(want).balanceOf(address(this));
        IERC20(want).safeApprove(curve, 0);
        IERC20(want).safeApprove(curve, _amount);
        uint256[4] memory vec = [
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0)
        ];
        vec[uint256(index)] = _amount;
        ICurveFi(curve).add_liquidity(vec, 0);
    }

    function WithdrawToken(uint256 _amount) internal override {
        IERC20(recv).safeApprove(curve, 0);
        IERC20(recv).safeApprove(curve, _amount);
        uint256[4] memory vec = [
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0)
        ];
        ICurveFi(curve).remove_liquidity(_amount, vec);

        for (int128 i = 0; i < 4; i++) {
            if (i == index) {
                continue;
            }
            address erc20 = ICurveFi(curve).coins(i);
            uint256 _bal = IERC20(erc20).balanceOf(address(this));
            if (_bal > 0) {
                IERC20(erc20).safeApprove(curve, 0);
                IERC20(erc20).safeApprove(curve, _bal);
                ICurveFi(curve).exchange(i, index, _bal, 0);
            }
        }
    }

    function GetPriceE18OfRecvInWant() public override view returns (uint256) {
        return
            ICurveFi(curve).get_virtual_price().mul(1e18).div(
                IYFIVault(want).getPricePerFullShare()
            );
    }
}
