// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Strategy.sol";
import "../../interfaces/external/AlcxStakingPools.sol";
import "../../interfaces/external/MetaCurvePools.sol";
import "../../interfaces/external/Uniswap.sol";

// owner == harvester
contract StrategyAlchemix is Strategy, Ownable {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address constant public alcx = 0xdBdb4d16EdA451D0503b854CF79D55697F90c8DF;
    address constant public sushiRouter = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address constant public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // used for alcx <> weth <> usdt route
    StakingPools public alcxStakingPools = StakingPools(0xAB8e74017a8Cc7c15FFcCd726603790d26d7DeCa);
    address constant public alcx3CrvCurvePool = 0x43b4FdFD4Ff969587185cDB6f0BD875c5Fc83f8c;
    MetaCurvePools public metaCurvePools = MetaCurvePools(0xA79828DF1850E8a3A3064576f380D90aECDD3359);
    uint256 constant public alcxCrvPoolId = 4;
    int128 constant public usdtIndexInCrvMetapool = 3;

    constructor(address _want) public Strategy(_want) {}

    function update(address _newStratrgy) public override {
        require(msg.sender == governance, "!governance");
        withdraw(1e18); // withdraw 100%
        uint256 _balance = IERC20(want).balanceOf(address(this));
        IERC20(want).safeTransfer(_newStratrgy, _balance);
        IVaultX(vaultX).setStrategy(_newStratrgy);
        IVaultY(vaultY).setStrategy(_newStratrgy);
    }

    function deposit(uint256 _ne18) public override {
        require(msg.sender == owner() || msg.sender == governance, "!authorized");
        uint256 _amount = IERC20(want).balanceOf(address(this)).mul(_ne18).div(1e18);
        IERC20(want).safeApprove(address(metaCurvePools), 0);
        IERC20(want).safeApprove(address(metaCurvePools), _amount);
        uint256[4] memory amountsToAdd = [
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(_amount)
        ];
        metaCurvePools.add_liquidity(alcx3CrvCurvePool, amountsToAdd, uint256(0)); // Vulnerable to sandwich attacks but only strategist and governnace can call this so no flash loans attacks + it's stableswap
        uint256 crvAmount = IERC20(alcx3CrvCurvePool).balanceOf(address(this));
        IERC20(alcx3CrvCurvePool).safeApprove(address(alcxStakingPools), 0);
        IERC20(alcx3CrvCurvePool).safeApprove(address(alcxStakingPools), crvAmount);
        alcxStakingPools.deposit(alcxCrvPoolId, crvAmount);
    }

    function withdrawByAmount(uint256 wantAmount) internal {
        uint256 lpAmount = wantAmount.mul(1e18).div(ICurveFi(alcx3CrvCurvePool).get_virtual_price());
        alcxStakingPools.withdraw(alcxCrvPoolId, lpAmount);
        IERC20(alcx3CrvCurvePool).safeApprove(address(metaCurvePools), 0);
        IERC20(alcx3CrvCurvePool).safeApprove(address(metaCurvePools), lpAmount);
        metaCurvePools.remove_liquidity_one_coin(address(alcx3CrvCurvePool), lpAmount, usdtIndexInCrvMetapool, wantAmount);
    }

    function harvest(uint minimumReceived) public { // Avoids sandwich attacks
        require(msg.sender == owner() || msg.sender == governance, "!authorized");
        alcxStakingPools.claim(alcxCrvPoolId);
        uint alcxBalance = IERC20(alcx).balanceOf(address(this));
        uint prevWantBalance = IERC20(want).balanceOf(address(this));
        if (alcxBalance > 0) {
            IERC20(alcx).safeApprove(sushiRouter, 0);
            IERC20(alcx).safeApprove(sushiRouter, alcxBalance);
            
            address[] memory path = new address[](3);
            path[0] = alcx;
            path[1] = weth;
            path[2] = want;
            
            IUniV2(sushiRouter).swapExactTokensForTokens(alcxBalance, minimumReceived, path, address(this), now.add(1800));
        }
        uint newWantBalance = IERC20(want).balanceOf(address(this));
        if (newWantBalance > prevWantBalance) {
            deposit(newWantBalance.sub(prevWantBalance).mul(1e18).div(newWantBalance));
        }
    }

    function withdraw(uint256 _ne18) public {
        require(msg.sender == governance, "!governance");
        uint256 _amount = alcxStakingPools.getStakeTotalDeposited(address(this), alcxCrvPoolId).mul(_ne18).div(1e18);
        if (_amount > 0) {
            withdrawByAmount(_amount);
        }
    }

    function safeWithdraw(uint256 _amount) public {
        require(msg.sender == governance, "!governance");
        withdrawByAmount(_amount);
    }

    function withdraw(address _to, uint256 _amount) public override {
        require(msg.sender == vaultX || msg.sender == vaultY, "!vault");

        uint256 _balance = IERC20(want).balanceOf(address(this));

        if (_balance < _amount) {
            withdrawByAmount(_amount.sub(_balance));
            _amount = Math.min(IERC20(want).balanceOf(address(this)), _amount);
        }

        if (msg.sender == vaultX) {
            uint256 _fee = _amount.mul(feexe18).div(1e18);
            IERC20(want).safeTransfer(governance, _fee);
            IERC20(want).safeTransfer(_to, _amount.sub(_fee));
        }
        else if (msg.sender == vaultY) {
            uint256 _fee = _amount.mul(feeye18).div(1e18);
            IERC20(want).safeTransfer(governance, _fee);
            IERC20(want).safeTransfer(_to, _amount.sub(_fee));
        }
    }

    function balanceOfY() public view override returns (uint256) {
        uint stakedCrv = alcxStakingPools.getStakeTotalDeposited(address(this), alcxCrvPoolId);
        uint balanceInCrv = ICurveFi(alcx3CrvCurvePool).get_virtual_price().mul(stakedCrv).div(1e18);
        return IERC20(want).balanceOf(address(this)).add(balanceInCrv).sub(IERC20(vaultX).totalSupply());
    }

    // needs a payable function in order to receive ETH when redeem cETH.
    receive() external payable {}
}