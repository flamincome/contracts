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

contract StrategyBaselineBenzeneCurveBTC is StrategyBaselineBenzene {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant curve = address(
        0x93054188d876f558f4a66B2EF1d97d16eDf0895B
    );
    int128 public index;

    constructor(int128 _index, address _controller)
        public
        StrategyBaselineBenzene(ICurveFiBTC(curve).coins(_index), _controller)
    {
        index = _index;
        SetRecv(address(0x49849c98ae39fff122806c06791fa73784fb3675));
    }

    function DepositToken(uint256 _amount) internal override {
        IERC20(want).safeApprove(curve, 0);
        IERC20(want).safeApprove(curve, _amount);
        uint256[2] memory vec = [uint256(0), uint256(0)];
        vec[uint256(index)] = _amount;
        ICurveFiBTC(curve).add_liquidity(vec, 0);
    }

    function WithdrawToken(uint256 _amount) internal override {
        IERC20(recv).safeApprove(curve, 0);
        IERC20(recv).safeApprove(curve, _amount);
        uint256[2] memory vec = [uint256(0), uint256(0)];
        ICurveFiBTC(curve).remove_liquidity(_amount, vec);

        for (int128 i = 0; i < 2; i++) {
            if (i == index) {
                continue;
            }
            address erc20 = ICurveFiBTC(curve).coins(i);
            uint256 _bal = IERC20(erc20).balanceOf(address(this));
            if (_bal > 0) {
                IERC20(erc20).safeApprove(curve, 0);
                IERC20(erc20).safeApprove(curve, _bal);
                ICurveFiBTC(curve).exchange(i, index, _bal, 0);
            }
        }
    }

    function GetPriceE18OfRecvInWant() public override view returns (uint256) {
        return ICurveFiBTC(curve).get_virtual_price().div(1e10);
    }
}
