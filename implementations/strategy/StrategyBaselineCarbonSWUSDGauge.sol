// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/Controller.sol";
import "../../interfaces/flamincome/Vault.sol";
import "../../interfaces/external/Gauge.sol";
import "../../interfaces/external/Curve.sol";
import "../../interfaces/external/Uniswap.sol";
import "../../interfaces/external/YFI.sol";

import "./StrategyBaselineCarbon.sol";

contract StrategyBaselineCarbonSWUSDGauge is StrategyBaselineCarbon {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant swusd = address(
        0x77C6E4a580c0dCE4E5c7a17d0bc077188a83A059
    );
    address public constant pool = address(
        0xb4d0C929cD3A1FbDc6d57E7D3315cF0C4d6B4bFa
    );
    address public constant mintr = address(
        0x2c988c3974AD7E604E276AE0294a7228DEf67974
    );
    address public constant swrv = address(
        0xB8BAa0e4287890a5F79863aB62b7F175ceCbD433
    );
    address public constant uni = address(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );
    address public constant weth = address(
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    );
    address public constant dai = address(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    address public constant swerve = address(
        0xa746c67eB7915Fa832a4C2076D403D4B68085431
    );

    constructor(address _controller)
        public
        StrategyBaselineCarbon(swusd, _controller)
    {}

    function DepositToken(uint256 _amount) internal override {
        IERC20(want).safeApprove(pool, 0);
        IERC20(want).safeApprove(pool, _amount);
        IGauge(pool).deposit(_amount);
    }

    function WithdrawToken(uint256 _amount) internal override {
        IGauge(pool).withdraw(_amount);
    }

    function Harvest() external override {
        require(msg.sender == Controller(controller).strategist() || msg.sender == governance, "!permission");
        IMintr(mintr).mint(pool);
        uint256 _swrv = IERC20(swrv).balanceOf(address(this));
        if (_swrv > 0) {
            uint256 _fee = _swrv.mul(feen).div(feed);
            IERC20(swrv).safeTransfer(Controller(controller).rewards(), _fee);
            _swrv = _swrv.sub(_fee);
            IERC20(swrv).safeApprove(uni, 0);
            IERC20(swrv).safeApprove(uni, _swrv);
            address[] memory path = new address[](3);
            path[0] = swrv;
            path[1] = weth;
            path[2] = dai;
            IUniV2(uni).swapExactTokensForTokens(
                _swrv,
                uint256(0),
                path,
                address(this),
                now.add(1800)
            );
            uint256 _dai = IERC20(dai).balanceOf(address(this));

            IERC20(dai).safeApprove(swerve, 0);
            IERC20(dai).safeApprove(swerve, _dai);
            uint256[4] memory vec = [
                uint256(0),
                uint256(0),
                uint256(0),
                uint256(0)
            ];
            vec[0] = _dai;
            ICurveFi(swerve).add_liquidity(vec, 0);
        }
    }

    function GetDeposited() public override view returns (uint256) {
        return IGauge(pool).balanceOf(address(this));
    }
}
