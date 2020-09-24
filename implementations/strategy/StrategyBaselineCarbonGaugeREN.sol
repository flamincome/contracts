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

contract StrategyBaselineCarbonGaugeBTC is StrategyBaselineCarbon {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant crvbtc = address(
        0x49849c98ae39fff122806c06791fa73784fb3675
    );
    address public constant pool = address(
        0xB1F2cdeC61db658F091671F5f199635aEF202CAC
    );
    address public constant mintr = address(
        0xd061D61a4d941c39E5453435B6345Dc261C2fcE0
    );
    address public constant crv = address(
        0xD533a949740bb3306d119CC777fa900bA034cd52
    );
    address public constant uni = address(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );
    address public constant weth = address(
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    );
    address public constant wbtc = address(
        0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599
    );
    address public constant curve = address(
        0x93054188d876f558f4a66B2EF1d97d16eDf0895B
    );

    constructor(address _controller)
        public
        StrategyBaselineCarbon(crvbtc, _controller)
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
        uint256 _crv = IERC20(crv).balanceOf(address(this));
        if (_crv > 0) {
            uint256 _fee = _crv.mul(feen).div(feed);
            IERC20(crv).safeTransfer(Controller(controller).rewards(), _fee);
            _crv = _crv.sub(_fee);
            IERC20(crv).safeApprove(uni, 0);
            IERC20(crv).safeApprove(uni, _crv);
            address[] memory path = new address[](3);
            path[0] = crv;
            path[1] = weth;
            path[2] = wbtc;
            IUniV2(uni).swapExactTokensForTokens(
                _crv,
                uint256(0),
                path,
                address(this),
                now.add(1800)
            );
            uint256 _wbtc = IERC20(wbtc).balanceOf(address(this));
            IERC20(wbtc).safeApprove(curve, 0);
            IERC20(wbtc).safeApprove(curve, _wbtc);
            uint256[2] memory vec = [
                uint256(0),
                uint256(0)
            ];
            vec[1] = _wbtc;
            ICurveFiBTC(curve).add_liquidity(vec, 0);
        }
    }

    function GetDeposited() public override view returns (uint256) {
        return IGauge(pool).balanceOf(address(this));
    }
}
