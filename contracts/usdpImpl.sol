// SPDX-License-Identifier: MIT

pragma solidity >0.7.0;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

interface UNI {
    function swapExactTokensForTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external;

    function getAmountsOut(uint256, address[] calldata)
        external
        returns (uint256[] memory);
}

interface CRV {
    function get_virtual_price() external view returns (uint256);
}

interface ConvexPool {
    function getReward(address _account, bool _claimExtras) external returns(bool);
    function withdrawAndUnwrap(uint256 amount, bool claim) external returns(bool);
    function balanceOf(address account) external view returns (uint256);
}

interface ConvexBooster {
    function deposit(uint256 _pid, uint256 _amount, bool _stake) external returns(bool);
}

interface ILP {
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);

    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function repay(
        address asset,
        uint256 amount,
        uint256 rateMode,
        address onBehalfOf
    ) external returns (uint256);

    function getReserveNormalizedIncome(address asset)
        external
        view
        returns (uint256);
}

interface MCP {
    function add_liquidity(
        uint256[4] calldata _deposit_amounts,
        uint256 _min_mint_amount
    ) external;

    function remove_liquidity(
        uint256 _burn_amount,
        uint256[4] calldata _min_amounts
    ) external;

    function calc_withdraw_one_coin(
        uint256 _token_amount,
        int128 i
    ) external view returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount
    ) external;
}

contract Impl_USDT_AaveV2_Alcx {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant token = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant atoken = 0x3Ed3B47Dd13EC9a98b44e6204A523E766B225811;
    address public constant cvx = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    address public constant crv = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address public constant ilp = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
    address public constant sushi = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 public constant pid = 28;
    address public constant convexPool = 0x24DfFd1949F888F91A0c8341Fc98a3F280a782a8;
    address public constant curveLPToken = 0x7Eb40E450b9655f4B3cC4259BCC731c63ff55ae6;
    address public constant curveZap = 0x3c8cAee4E09296800f8D29A68Fa3837e2dae4940;
    address public constant curveBooster = 0xF403C135812408BFbE8713b5A23a04b3D48AAE31;
    address public constant curvePool = 0x42d7025938bEc20B69cBae5A77421082407f053A;

    function dohardwork(bytes memory _data) public {
        uint256[] memory _ne18s = abi.decode(_data, (uint256[]));
        for (uint256 _i = 0; _i < _ne18s.length; _i++) {
            deposit(_ne18s[_i]);
        }
    }

    function deposit(uint256 _ne18) public {
        if (_ne18 == 0) {
            work_claim_rewards(5e16);
            return;
        }
        if (_ne18 <= 1e18) {
            work_deposit_to_aave(_ne18);
            return;
        }
        if (_ne18 <= 2e18) {
            work_withdraw_from_aave(_ne18.sub(1e18));
            return;
        }
        if (_ne18 <= 3e18) {
            work_deposit_to_convex(_ne18.sub(2e18));
            return;
        }
        if (_ne18 <= 4e18) {
            work_withdraw_from_convex(_ne18.sub(3e18));
            return;
        }
        if (_ne18 <= 5e18) {
            work_trade_on_sushi(crv, _ne18.sub(4e18));
            return;
        }
        if (_ne18 <= 6e18) {
            work_trade_with_strategist(crv, _ne18.sub(5e18));
            return;
        }
        if (_ne18 <= 7e18) {
            work_trade_on_sushi(cvx, _ne18.sub(6e18));
            return;
        }
        if (_ne18 <= 8e18) {
            work_trade_with_strategist(cvx, _ne18.sub(7e18));
            return;
        }
    }

    function withdraw(uint256 _ne18) public {
        uint256 _amt = IERC20(atoken).balanceOf(address(this));
        if (_amt == 0) {
            return;
        }
        uint256 _amt0 = ConvexPool(convexPool).balanceOf(address(this));
        _amt0 = CRV(curvePool).get_virtual_price().mul(_amt0).div(1e18).div(1e12);
        _ne18 = _ne18.mul(_amt0).div(_amt).add(_ne18);
        work_withdraw_from_aave(_ne18);
    }

    function deposited() public view returns (uint256) {
        uint256 _amt = ConvexPool(convexPool).balanceOf(address(this));
        _amt = CRV(curvePool).get_virtual_price().mul(_amt).div(1e18).div(1e12);
        _amt = IERC20(atoken).balanceOf(address(this)).add(_amt);
        return _amt;
    }

    function work_claim_rewards(uint256 _ne18) internal {
        uint256 _amtCvx = IERC20(cvx).balanceOf(address(this));
        uint256 _amtCrv = IERC20(crv).balanceOf(address(this));
        ConvexPool(convexPool).getReward(address(this), true);
        _amtCvx = IERC20(cvx).balanceOf(address(this)).sub(_amtCvx);
        _amtCvx = _amtCvx.mul(_ne18).div(1e18);
        _amtCrv = IERC20(crv).balanceOf(address(this)).sub(_amtCrv);
        _amtCrv = _amtCrv.mul(_ne18).div(1e18);
        IERC20(cvx).transfer(tx.origin, _amtCvx);
        IERC20(crv).transfer(tx.origin, _amtCrv);
    }

    function work_deposit_to_aave(uint256 _ne18) internal {
        uint256 _amt = IERC20(token).balanceOf(address(this));
        _amt = _amt.mul(_ne18).div(1e18);
        if (_amt == 0) {
            return;
        }
        IERC20(token).safeApprove(ilp, 0);
        IERC20(token).safeApprove(ilp, _amt);
        ILP(ilp).deposit(token, _amt, address(this), 0);
    }

    function work_withdraw_from_aave(uint256 _ne18) internal {
        uint256 _amt = IERC20(atoken).balanceOf(address(this));
        _amt = _amt.mul(_ne18).div(1e18);
        if (_amt == 0) {
            return;
        }
        ILP(ilp).withdraw(token, _amt, address(this));
    }

    function work_deposit_to_convex(uint256 _ne18) internal {
        uint256 _amt = IERC20(token).balanceOf(address(this));
        _amt = _amt.mul(_ne18).div(1e18);
        IERC20(token).safeApprove(curveZap, 0);
        IERC20(token).safeApprove(curveZap, _amt);
        uint256[4] memory _deposit_amounts = [0, 0, 0, _amt];
        MCP(curveZap).add_liquidity(_deposit_amounts, 0);
        _amt = IERC20(curveLPToken).balanceOf(address(this));
        IERC20(curveLPToken).safeApprove(curveBooster, 0);
        IERC20(curveLPToken).safeApprove(curveBooster, _amt);
        ConvexBooster(curveBooster).deposit(pid, _amt, true);
    }

    function work_withdraw_from_convex(uint256 _ne18) internal {
        uint256 _amt = ConvexPool(convexPool).balanceOf(address(this));
        _amt = _amt.mul(_ne18).div(1e18);
        ConvexPool(convexPool).withdrawAndUnwrap(_amt, false); // claim = false
        IERC20(curveLPToken).safeApprove(curveZap, 0);
        IERC20(curveLPToken).safeApprove(curveZap, _amt);
        MCP(curveZap).remove_liquidity_one_coin(_amt, 3, 0);
    }

    function work_trade_on_sushi(address tokenToTrade, uint256 _ne18) internal {
        uint256 _amt = IERC20(tokenToTrade).balanceOf(address(this));
        _amt = _amt.mul(_ne18).div(1e18);
        IERC20(tokenToTrade).safeApprove(sushi, 0);
        IERC20(tokenToTrade).safeApprove(sushi, _amt);
        address[] memory _p = new address[](3);
        _p[0] = tokenToTrade;
        _p[1] = weth;
        _p[2] = token;
        uint256 _t = block.timestamp.add(1800);
        UNI(sushi).swapExactTokensForTokens(_amt, 0, _p, address(this), _t);
    }

    function work_trade_with_strategist(address tokenToTrade, uint256 _ne18) internal {
        uint256 _amt = IERC20(tokenToTrade).balanceOf(address(this));
        _amt = _amt.mul(_ne18).div(1e18);
        address[] memory _p = new address[](3);
        _p[0] = tokenToTrade;
        _p[1] = weth;
        _p[2] = token;
        uint256 _recv = UNI(sushi).getAmountsOut(_amt, _p)[2];
        IERC20(token).safeTransferFrom(tx.origin, address(this), _recv);
        IERC20(tokenToTrade).safeTransfer(tx.origin, _amt);
    }
}