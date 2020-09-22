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

contract StrategyBaselineCarbonUniswapBTC is StrategyBaselineCarbon {
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
        StakingRewards(lppool).stake(_amount);
    }

    function WithdrawToken(uint256 _amount) internal override {
        StakingRewards(lppool).withdraw(_amount);
    }

    function Harvest() external override {
        require(msg.sender == Controller(controller).strategist() || msg.sender == governance, "!permission");
        StakingRewards(lppool).getReward();
        uint256 unitokenBalance = IERC20(unitoken).balanceOf(address(this));

        uint256 amountOutMin = 1;

        IERC20(unitoken).safeApprove(uniswapRouterV2, 0);
        IERC20(unitoken).safeApprove(uniswapRouterV2, unitokenBalance);

        // sell Uni to weth
        address[] memory path1 = new address[](2);
        path1[0] = unitoken;
        path1[1] = weth;
        UniswapV2Router02(uniswapRouterV2).swapExactTokensForTokens(
            unitokenBalance,
            amountOutMin,
            path1,
            address(this),
            block.timestamp
        );

        uint256 wethAmount = IERC20(weth).balanceOf(address(this));

        // sell weth/2 to wbtc
        uint256 sellWETHAmount = wethAmount / 2;
        IERC20(weth).safeApprove(uniswapRouterV2, 0);
        IERC20(weth).safeApprove(uniswapRouterV2, sellWETHAmount);
        address[] memory path2 = new address[](2);
        path2[0] = weth;
        path2[1] = wbtc; 
        UniswapV2Router02(uniswapRouterV2).swapExactTokensForTokens(
            sellWETHAmount,
            amountOutMin,
            path2,
            address(this),
            block.timestamp
        );

        wethAmount = IERC20(weth).balanceOf(address(this));
        uint256 wbtcAmount = IERC20(wbtc).balanceOf(address(this));

        // provide weth and wbtc to UniLPToken

        IERC20(weth).safeApprove(uniswapRouterV2, 0);
        IERC20(weth).safeApprove(uniswapRouterV2, wethAmount);

        IERC20(wbtc).safeApprove(uniswapRouterV2, 0);
        IERC20(wbtc).safeApprove(uniswapRouterV2, wbtcAmount);

        uint256 liquidity;
        (,,liquidity) = UniswapV2Router02(uniswapRouterV2).addLiquidity(
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

    function GetDeposited() public override view returns (uint256) {
        return StakingRewards(lppool).balanceOf(address(this));
    }
}
