// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/Controller.sol";
import "../../interfaces/flamincome/Vault.sol";
import "../../interfaces/external/Uniswap.sol";

import "./StrategyBaselineCarbon.sol";

contract StrategyBaselineCarbonUniswapWBTCResilient is StrategyBaselineCarbon {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant unitoken = address(
        0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984
    );
    address public constant lptoken = address(
        0xBb2b8038a1640196FbE3e38816F3e67Cba72D940
    );
    address public constant lppool = address(
        0xCA35e32e7926b96A9988f61d510E038108d8068e
    );
    address public constant unipool = address(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );
    address public constant weth = address(
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    );
    address public constant wbtc = address(
        0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599
    );
    address public constant uniswapRouterV2 = address(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );

    constructor(address _controller)
        public
        StrategyBaselineCarbon(lptoken, _controller)
    {}

    function DepositToken(uint256 _amount) internal override {
        IERC20(want).safeApprove(lppool, 0);
        IERC20(want).safeApprove(lppool, _amount);
        IUniStakingRewards(lppool).stake(_amount);
    }

    function WithdrawToken(uint256 _amount) internal override {
        IUniStakingRewards(lppool).withdraw(_amount);
    }

    function WithdrawTokenPublic(uint256 _amount) public {
        require(
            msg.sender == Controller(controller).strategist() || msg.sender == governance,
            "!permission"
        );
        IUniStakingRewards(lppool).withdraw(_amount);
    }

    function AddLiquidity() public {
        require(
            msg.sender == Controller(controller).strategist() || msg.sender == governance,
            "!permission"
        );
        uint256 wethAmount = IERC20(weth).balanceOf(address(this));
        uint256 wbtcAmount = IERC20(wbtc).balanceOf(address(this));
        IERC20(weth).safeApprove(uniswapRouterV2, 0);
        IERC20(weth).safeApprove(uniswapRouterV2, wethAmount);
        IERC20(wbtc).safeApprove(uniswapRouterV2, 0);
        IERC20(wbtc).safeApprove(uniswapRouterV2, wbtcAmount);
        IUniswapV2Router02(uniswapRouterV2).addLiquidity(
            weth,
            wbtc,
            wethAmount,
            wbtcAmount,
            1,
            1,
            address(this),
            block.timestamp
        );
        wethAmount = IERC20(weth).balanceOf(address(this));
        wbtcAmount = IERC20(wbtc).balanceOf(address(this));
        while (wethAmount > 0 || wbtcAmount > 0) {
            if (wethAmount > 0) {
                wethAmount = IERC20(weth).balanceOf(address(this));
                IERC20(weth).safeApprove(uniswapRouterV2, 0);
                IERC20(weth).safeApprove(uniswapRouterV2, wethAmount);
                address[] memory path2 = new address[](2);
                path2[0] = weth;
                path2[1] = wbtc;
                IUniswapV2Router02(uniswapRouterV2).swapExactTokensForTokens(
                    wethAmount.div(2),
                    0,
                    path2,
                    address(this),
                    block.timestamp
                );
            }
            if (wbtcAmount > 0) {
                wbtcAmount = IERC20(wbtc).balanceOf(address(this));
                IERC20(wbtc).safeApprove(uniswapRouterV2, 0);
                IERC20(wbtc).safeApprove(uniswapRouterV2, wbtcAmount);
                address[] memory path2 = new address[](2);
                path2[0] = wbtc;
                path2[1] = weth;
                IUniswapV2Router02(uniswapRouterV2).swapExactTokensForTokens(
                    wbtcAmount.div(2),
                    0,
                    path2,
                    address(this),
                    block.timestamp
                );
            }
            wethAmount = IERC20(weth).balanceOf(address(this));
            wbtcAmount = IERC20(wbtc).balanceOf(address(this));
            IERC20(weth).safeApprove(uniswapRouterV2, 0);
            IERC20(weth).safeApprove(uniswapRouterV2, wethAmount);
            IERC20(wbtc).safeApprove(uniswapRouterV2, 0);
            IERC20(wbtc).safeApprove(uniswapRouterV2, wbtcAmount);
            IUniswapV2Router02(uniswapRouterV2).addLiquidity(
                weth,
                wbtc,
                wethAmount,
                wbtcAmount,
                1,
                1,
                address(this),
                block.timestamp
            );
        }
    }

    function RemoveLiquidity() public {
        require(
            msg.sender == Controller(controller).strategist() || msg.sender == governance,
            "!permission"
        );
        uint256 lptokenAmount = IERC20(lptoken).balanceOf(address(this));
        IERC20(lptoken).safeApprove(uniswapRouterV2, 0);
        IERC20(lptoken).safeApprove(uniswapRouterV2, lptokenAmount);
        IUniswapV2Router02(uniswapRouterV2).removeLiquidity(
            weth,
            wbtc,
            lptokenAmount,
            1,
            1,
            address(this),
            block.timestamp
        );
    }

    function Harvest() external override {
        require(
            msg.sender == Controller(controller).strategist() ||
                msg.sender == governance,
            "!permission"
        );
        IUniStakingRewards(lppool).getReward();
        uint256 unitokenBalance = IERC20(unitoken).balanceOf(address(this));

        if (unitokenBalance > 0) {
            uint256 _fee = unitokenBalance.mul(feen).div(feed);
            IERC20(unitoken).safeTransfer(Controller(controller).rewards(), _fee);
            unitokenBalance = unitokenBalance.sub(_fee);

            IERC20(unitoken).safeApprove(uniswapRouterV2, 0);
            IERC20(unitoken).safeApprove(uniswapRouterV2, unitokenBalance);
            address[] memory path1 = new address[](2);
            path1[0] = unitoken;
            path1[1] = weth;
            IUniswapV2Router02(uniswapRouterV2).swapExactTokensForTokens(
                unitokenBalance,
                0,
                path1,
                address(this),
                block.timestamp
            );

            uint256 wethAmount = IERC20(weth).balanceOf(address(this));
            IERC20(weth).safeApprove(uniswapRouterV2, 0);
            IERC20(weth).safeApprove(uniswapRouterV2, wethAmount);
            address[] memory path2 = new address[](2);
            path2[0] = weth;
            path2[1] = wbtc;
            IUniswapV2Router02(uniswapRouterV2).swapExactTokensForTokens(
                wethAmount.div(2),
                0,
                path2,
                address(this),
                block.timestamp
            );

            wethAmount = IERC20(weth).balanceOf(address(this));
            uint256 wbtcAmount = IERC20(wbtc).balanceOf(address(this));

            IERC20(wbtc).safeApprove(uniswapRouterV2, 0);
            IERC20(wbtc).safeApprove(uniswapRouterV2, wbtcAmount);

            IUniswapV2Router02(uniswapRouterV2).addLiquidity(
                weth,
                wbtc,
                wethAmount,
                wbtcAmount,
                1,
                1,
                address(this),
                block.timestamp
            );
        }
    }

    function GetDeposited() public override view returns (uint256) {
        uint256 lpTokenAmountInPool = IUniStakingRewards(lppool).balanceOf(address(this));
        uint256 lpTokenAmountReserved = IERC20(lptoken).balanceOf(address(this));
        return lpTokenAmountInPool.add(lpTokenAmountReserved);
    }
}
