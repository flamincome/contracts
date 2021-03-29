// SPDX-License-Identifier: MIT

pragma solidity >0.7.0;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

interface UniRouter {
    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external;
    function getAmountsOut(uint, address[] calldata) external returns (uint[] memory);
}

interface ICurveFi {
  function get_virtual_price() external view returns (uint);
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
        address _pool,
        uint256[4] calldata _deposit_amounts,
        uint256 _min_mint_amount
    ) external;

    function remove_liquidity(
        address _pool,
        uint256 _burn_amount,
        uint256[4] calldata _min_amounts
    ) external;

    function calc_withdraw_one_coin(
        address _pool,
        uint256 _token_amount,
        int128 i
    ) external view returns (uint256);

    function remove_liquidity_one_coin(
        address _pool,
        uint256 _token_amount,
        int128 i,
        uint256 min_amount
    ) external;
}

interface ASP {
    function deposit(uint256 _poolId, uint256 _depositAmount) external;

    function withdraw(uint256 _poolId, uint256 _withdrawAmount) external;

    function claim(uint256 _poolId) external;

    function exit(uint256 _poolId) external;

    function getPoolTotalDeposited(uint256 _poolId)
        external
        view
        returns (uint256);

    function getStakeTotalDeposited(address _account, uint256 _poolId)
        external
        view
        returns (uint256);

    function getStakeTotalUnclaimed(address _account, uint256 _poolId)
        external
        view
        returns (uint256);
}

contract Impl_USDT_AaveV2_Alcx {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant token = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant atoken = 0x3Ed3B47Dd13EC9a98b44e6204A523E766B225811;
    address public constant alcx = 0xdBdb4d16EdA451D0503b854CF79D55697F90c8DF;
    address public constant ilp = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
    address public constant mcp = 0xA79828DF1850E8a3A3064576f380D90aECDD3359;
    address public constant bcp = 0x43b4FdFD4Ff969587185cDB6f0BD875c5Fc83f8c; // alUSD <> 3CRV pool
    address public constant asp = 0xAB8e74017a8Cc7c15FFcCd726603790d26d7DeCa;
    address constant public sushiRouter = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address constant public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // used for alcx <> weth <> usdt route
    uint256 public constant pid = 4;
    uint256 public constant DENOMINATOR = 10000;

    function dohardwork(bytes memory _data) public {
        uint256 _ne18 = abi.decode(_data, (uint256));
        if (_ne18 == 0) {
            // CLAIM ALCX
            ASP(asp).claim(pid);
        } else if (_ne18 <= 1e18) {
            // DEPOSIT TO ALCX
            uint256 _amt = IERC20(token).balanceOf(address(this));
            _amt = _amt.mul(_ne18).div(1e18);
            IERC20(token).safeApprove(mcp, 0);
            IERC20(token).safeApprove(mcp, _amt);
            uint256[4] memory _deposit_amounts = [0, 0, 0, _amt];
            MCP(mcp).add_liquidity(bcp, _deposit_amounts, 0); // FIX THE LAST 0 for anti-sandwich
            _amt = IERC20(bcp).balanceOf(address(this));
            IERC20(bcp).safeApprove(asp, 0);
            IERC20(bcp).safeApprove(asp, _amt);
            ASP(asp).deposit(pid, _amt);
        } else if (_ne18 <= 2e18) {
            // WITHDRAW TO ONE COIN FROM ALCX
            _ne18 = _ne18.sub(1e18);
            uint256 _amt = ASP(asp).getStakeTotalDeposited(address(this), pid);
            uint slip = _ne18.div(1e15); // First 3 bits -> slip
            uint percentWithdraw = _ne18.mod(1e15); // Next 14 bits -> amount to withdraw
            _amt = _amt.mul(percentWithdraw).div(1e15);
            ASP(asp).withdraw(pid, _amt);
            IERC20(bcp).safeApprove(mcp, 0);
            IERC20(bcp).safeApprove(mcp, _amt);
            MCP(mcp).remove_liquidity_one_coin(bcp, _amt, 3, _amnt.mul(DENOMINATOR.sub(slip)).div(DENOMINATOR));
        } else if (_ne18 <= 3e18) {
            // WITHDRAW TO MULTI COINS FROM ALCX
            _ne18 = _ne18.sub(2e18);
            uint256 _amt = ASP(asp).getStakeTotalDeposited(address(this), pid);
            _amt = _amt.mul(_ne18).div(1e18);
            ASP(asp).withdraw(pid, _amt);
            IERC20(bcp).safeApprove(mcp, 0);
            IERC20(bcp).safeApprove(mcp, _amt);
            uint256[4] memory minAmounts = [
                uint256(0),
                uint256(0),
                uint256(0),
                uint256(0)
            ];
            MCP(mcp).remove_liquidity(bcp, _amt, minAmounts);
        } else if (_ne18 <= 4e18) {
            // TRADE ALCX ON SUSHI
            _ne18 = _ne18.sub(3e18);
            uint minimumReceived = _ne18.mul(1e6);
            uint256 alcxBalance = IERC20(alcx).balanceOf(address(this));
            IERC20(alcx).safeApprove(sushiRouter, 0);
            IERC20(alcx).safeApprove(sushiRouter, alcxBalance);

            address[] memory path = new address[](3);
            path[0] = alcx;
            path[1] = weth;
            path[2] = token;

            UniRouter(sushiRouter).swapExactTokensForTokens(
                alcxBalance,
                minimumReceived,
                path,
                address(this),
                block.timestamp.add(1800)
            );
        } else if (_ne18 <= 5e18) {
            // TRADE ALCX WITH STRATEGIST
            _ne18 = _ne18.sub(3e18);
            uint amountReceived = _ne18.mul(1e6);
            uint256 alcxBalance = IERC20(alcx).balanceOf(address(this));
            address[] memory path = new address[](3);
            path[0] = alcx;
            path[1] = weth;
            path[2] = token;
            uint receivedFromSushi = UniRouter(sushiRouter).getAmountsOut(alcxBalance, path)[2];
            require(receivedFromSushi < amountReceived, "sushi is better");
            IERC20(token).safeTransferFrom(tx.origin, address(this), amountReceived);
            IERC20(alcx).safeTransfer(tx.origin, alcxBalance);
        } else if (_ne18 <= 6e18) {
            // TRADE UNDERLYING USD WITH STRATEGIST

        }
    }

    function deposit(uint256 _ne18) public {
        uint256 _amt = IERC20(token).balanceOf(address(this));
        _amt = _amt.mul(_ne18).div(1e18);
        if (_amt == 0) {
            return;
        }
        IERC20(token).safeApprove(ilp, 0);
        IERC20(token).safeApprove(ilp, _amt);
        ILP(ilp).deposit(token, _amt, address(this), 0);
    }

    function withdraw(uint256 _ne18) public {
        uint256 _amt = IERC20(atoken).balanceOf(address(this));
        _amt = _amt.mul(_ne18).div(1e18);
        if (_amt == 0) {
            return;
        }
        ILP(ilp).withdraw(token, _amt, address(this));
        // TODO: SHOULD WE WITHDRAW FROM ALCX WHEN THERE IS NO ENOUGH USDT IN AAVE
        // TODO: OR AN ADDTIONAL SLIPPAGE LIMIT SHOULD BE ADDED TO PROTECT USERS
        // Let's not allow withdrawals from users on curve?
    }

    function deposited() public view returns (uint256) {
        uint256 _amt = ASP(asp).getStakeTotalDeposited(address(this), pid);
        _amt = _amt.mul(ICurveFi(bcp).get_virtual_price()).div(1e18); // Maybe this is wrong, since this is a metapool we might have to get the price of the metapool and then the price of 3crv
        _amt = IERC20(atoken).balanceOf(address(this)).add(_amt);
        return _amt;
    }
}
