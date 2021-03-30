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

// interface CRV {
//     function get_virtual_price() external view returns (uint256);
// }

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

// interface MCP {
//     function add_liquidity(
//         address _pool,
//         uint256[4] calldata _deposit_amounts,
//         uint256 _min_mint_amount
//     ) external;

//     function remove_liquidity(
//         address _pool,
//         uint256 _burn_amount,
//         uint256[4] calldata _min_amounts
//     ) external;

//     function calc_withdraw_one_coin(
//         address _pool,
//         uint256 _token_amount,
//         int128 i
//     ) external view returns (uint256);

//     function remove_liquidity_one_coin(
//         address _pool,
//         uint256 _token_amount,
//         int128 i,
//         uint256 min_amount
//     ) external;
// }

// interface ASP {
//     function deposit(uint256 _poolId, uint256 _depositAmount) external;

//     function withdraw(uint256 _poolId, uint256 _withdrawAmount) external;

//     function claim(uint256 _poolId) external;

//     function exit(uint256 _poolId) external;

//     function getPoolTotalDeposited(uint256 _poolId)
//         external
//         view
//         returns (uint256);

//     function getStakeTotalDeposited(address _account, uint256 _poolId)
//         external
//         view
//         returns (uint256);

//     function getStakeTotalUnclaimed(address _account, uint256 _poolId)
//         external
//         view
//         returns (uint256);
// }

contract Impl_USDT_AaveV2_Alcx {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant token = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public constant atoken = 0x9ff58f4fFB29fA2266Ab25e75e2A8b3503311656;
    address public constant ilp = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
    address public constant badger = 0x3472A5A71965499acd81997a54BBA8D852C6E53d;
    address public constant digg = 0x798D1bE841a82a273720CE31c822C61a67a601C3;
    address public constant uni = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant sushi = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;

    // address public constant mcp = 0xA79828DF1850E8a3A3064576f380D90aECDD3359;
    // address public constant bcp = 0x43b4FdFD4Ff969587185cDB6f0BD875c5Fc83f8c;
    // address public constant asp = 0xAB8e74017a8Cc7c15FFcCd726603790d26d7DeCa;
    // address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // uint256 public constant pid = 4;

    function dohardwork(bytes memory _data) public {
        uint256[] memory _ne18s = abi.decode(_data, (uint256[]));
        for (uint256 _i = 0; _i < _ne18s.length; _i++) {
            deposit(_ne18s[_i]);
        }
    }

    function deposit(uint256 _ne18) public {
        if (_ne18 == 0) {
            work_claim_badger(5e16);
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
            work_deposit_to_badger(_ne18.sub(2e18));
            return;
        }
        if (_ne18 <= 4e18) {
            work_withdraw_from_badger(_ne18.sub(3e18));
            return;
        }
        if (_ne18 <= 5e18) {
            work_trade_badger_on_uni(_ne18.sub(4e18));
            return;
        }
        if (_ne18 <= 6e18) {
            work_trade_badger_on_sushi(_ne18.sub(5e18));
            return;
        }
        if (_ne18 <= 7e18) {
            work_trade_badger_with_strategist(_ne18.sub(6e18));
            return;
        }
        if (_ne18 <= 8e18) {
            work_trade_digg_on_uni(_ne18.sub(7e18));
            return;
        }
        if (_ne18 <= 9e18) {
            work_trade_digg_on_sushi(_ne18.sub(8e18));
            return;
        }
        if (_ne18 <= 1e19) {
            work_trade_digg_with_strategist(_ne18.sub(9e18));
            return;
        }
    }

    function withdraw(uint256 _ne18) public {
        work_withdraw_from_aave(_ne18);
    }

    function deposited() public view returns (uint256) {
        uint256 _amt = 0; // FIXME
        // uint256 _amt = ASP(asp).getStakeTotalDeposited(address(this), pid);
        // _amt = CRV(bcp).get_virtual_price().mul(_amt).div(1e18).div(1e12);
        _amt = IERC20(atoken).balanceOf(address(this)).add(_amt);
        return _amt;
    }

    function work_claim_badger(uint256 _ne18) internal {
        // uint256 _amt = IERC20(alcx).balanceOf(address(this));
        // ASP(asp).claim(pid);
        // _amt = IERC20(alcx).balanceOf(address(this)).sub(_amt);
        // _amt = _amt.mul(_ne18).div(1e18);
        // IERC20(alcx).transfer(tx.origin, _amt);
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

    function work_deposit_to_badger(uint256 _ne18) internal {
        // uint256 _amt = IERC20(token).balanceOf(address(this));
        // _amt = _amt.mul(_ne18).div(1e18);
        // IERC20(token).safeApprove(mcp, 0);
        // IERC20(token).safeApprove(mcp, _amt);
        // uint256[4] memory _deposit_amounts = [0, 0, 0, _amt];
        // MCP(mcp).add_liquidity(bcp, _deposit_amounts, 0);
        // _amt = IERC20(bcp).balanceOf(address(this));
        // IERC20(bcp).safeApprove(asp, 0);
        // IERC20(bcp).safeApprove(asp, _amt);
        // ASP(asp).deposit(pid, _amt);
    }

    function work_withdraw_from_badger(uint256 _ne18) internal {
        // uint256 _amt = ASP(asp).getStakeTotalDeposited(address(this), pid);
        // _amt = _amt.mul(_ne18).div(1e18);
        // ASP(asp).withdraw(pid, _amt);
        // IERC20(bcp).safeApprove(mcp, 0);
        // IERC20(bcp).safeApprove(mcp, _amt);
        // MCP(mcp).remove_liquidity_one_coin(bcp, _amt, 3, 0);
    }

    function work_trade_badger_on_uni(uint256 _ne18) internal {
        uint256 _amt = IERC20(badger).balanceOf(address(this));
        _amt = _amt.mul(_ne18).div(1e18);
        IERC20(badger).safeApprove(uni, 0);
        IERC20(badger).safeApprove(uni, _amt);
        address[] memory _p = new address[](2);
        _p[0] = badger;
        _p[1] = token;
        uint256 _t = block.timestamp.add(1800);
        UNI(uni).swapExactTokensForTokens(_amt, 0, _p, address(this), _t);
    }

    function work_trade_badger_on_sushi(uint256 _ne18) internal {
        uint256 _amt = IERC20(badger).balanceOf(address(this));
        _amt = _amt.mul(_ne18).div(1e18);
        IERC20(badger).safeApprove(sushi, 0);
        IERC20(badger).safeApprove(sushi, _amt);
        address[] memory _p = new address[](2);
        _p[0] = badger;
        _p[1] = token;
        uint256 _t = block.timestamp.add(1800);
        UNI(sushi).swapExactTokensForTokens(_amt, 0, _p, address(this), _t);
    }

    function work_trade_badger_with_strategist(uint256 _ne18) internal {
        uint256 _amt = IERC20(badger).balanceOf(address(this));
        _amt = _amt.mul(_ne18).div(1e18);
        address[] memory _p = new address[](2);
        _p[0] = badger;
        _p[1] = token;
        uint256 _recv = UNI(uni).getAmountsOut(_amt, _p)[1];
        IERC20(token).safeTransferFrom(tx.origin, address(this), _recv);
        IERC20(badger).safeTransfer(tx.origin, _amt);
    }

    function work_trade_digg_on_uni(uint256 _ne18) internal {
        uint256 _amt = IERC20(digg).balanceOf(address(this));
        _amt = _amt.mul(_ne18).div(1e18);
        IERC20(digg).safeApprove(uni, 0);
        IERC20(digg).safeApprove(uni, _amt);
        address[] memory _p = new address[](2);
        _p[0] = digg;
        _p[1] = token;
        uint256 _t = block.timestamp.add(1800);
        UNI(uni).swapExactTokensForTokens(_amt, 0, _p, address(this), _t);
    }

    function work_trade_digg_on_sushi(uint256 _ne18) internal {
        uint256 _amt = IERC20(digg).balanceOf(address(this));
        _amt = _amt.mul(_ne18).div(1e18);
        IERC20(digg).safeApprove(sushi, 0);
        IERC20(digg).safeApprove(sushi, _amt);
        address[] memory _p = new address[](2);
        _p[0] = digg;
        _p[1] = token;
        uint256 _t = block.timestamp.add(1800);
        UNI(sushi).swapExactTokensForTokens(_amt, 0, _p, address(this), _t);
    }

    function work_trade_digg_with_strategist(uint256 _ne18) internal {
        uint256 _amt = IERC20(digg).balanceOf(address(this));
        _amt = _amt.mul(_ne18).div(1e18);
        address[] memory _p = new address[](2);
        _p[0] = digg;
        _p[1] = token;
        uint256 _recv = UNI(uni).getAmountsOut(_amt, _p)[1];
        IERC20(token).safeTransferFrom(tx.origin, address(this), _recv);
        IERC20(digg).safeTransfer(tx.origin, _amt);
    }
}
