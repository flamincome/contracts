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

contract StrategyBaselineCarbonGauge is StrategyBaselineCarbon {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant ycrv = address(
        0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8
    );
    address public constant pool = address(
        0xFA712EE4788C042e2B7BB55E6cb8ec569C4530c1
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
    address public constant dai = address(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    address public constant ydai = address(
        0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01
    );
    address public constant curve = address(
        0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51
    );

    constructor(address _controller)
        public
        StrategyBaselineCarbon(ycrv, _controller)
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
            path[2] = dai;
            IUniV2(uni).swapExactTokensForTokens(
                _crv,
                uint256(0),
                path,
                address(this),
                now.add(1800)
            );
            uint256 _dai = IERC20(dai).balanceOf(address(this));
            IERC20(dai).safeApprove(ydai, 0);
            IERC20(dai).safeApprove(ydai, _dai);
            IYFIVault(ydai).deposit(_dai);
            uint256 _ydai = IERC20(ydai).balanceOf(address(this));
            IERC20(ydai).safeApprove(curve, 0);
            IERC20(ydai).safeApprove(curve, _ydai);
            uint256[4] memory vec = [
                uint256(0),
                uint256(0),
                uint256(0),
                uint256(0)
            ];
            vec[0] = _ydai;
            ICurveFi(curve).add_liquidity(vec, 0);
        }
    }

    function GetDeposited() public override view returns (uint256) {
        return IGauge(pool).balanceOf(address(this));
    }
}
