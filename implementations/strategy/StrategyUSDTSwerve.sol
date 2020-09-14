// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/Controller.sol";
import "../../interfaces/flamincome/Vault.sol";
import "../../interfaces/external/Swerve.sol";

contract StrategyUSDTSwerve {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address constant public want = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address constant public swerve = address(0xa746c67eB7915Fa832a4C2076D403D4B68085431);
    address constant public swusd = address(0x77C6E4a580c0dCE4E5c7a17d0bc077188a83A059);
    address constant public flamswusd = address(0x2E5d55e4BF8ee14e17ed87B3aE3A82B7782E9d57);
    address constant public dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address constant public usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant public usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address constant public tusd = address(0x0000000000085d4780B73119b644AE5ecd22b376);
    
    address public governance;
    address public controller;
    
    constructor(address _controller) public {
        governance = msg.sender;
        controller = _controller;
    }
    
    function deposit() public {
        uint _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            IERC20(want).safeApprove(swerve, 0);
            IERC20(want).safeApprove(swerve, _want);
            ISwerveFi(swerve).add_liquidity([uint256(0), uint256(0), _want, uint256(0)], 0);
        }
        uint _swusd = IERC20(swusd).balanceOf(address(this));
        if (_swusd > 0) {
            IERC20(swusd).safeApprove(flamswusd, 0);
            IERC20(swusd).safeApprove(flamswusd, _swusd);
            Vault(flamswusd).deposit(_swusd);
        }
    }
    
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        require(swusd != address(_asset), "swusd");
        require(flamswusd != address(_asset), "flamswusd");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }
    
    function withdraw(uint _amount) external {
        require(msg.sender == controller, "!controller");
        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _amount.sub(_balance);
            uint _flamswusd = IERC20(flamswusd).balanceOf(address(this));
            Vault(flamswusd).withdraw(_flamswusd);
            uint _swusd = IERC20(swusd).balanceOf(address(this));
            uint _maximum = ISwerveFi(swerve).calc_withdraw_one_coin(_swusd, 2);
            IERC20(swusd).safeApprove(swerve, 0);
            IERC20(swusd).safeApprove(swerve, _swusd);
            if (_amount < _maximum) {
                ISwerveFi(swerve).remove_liquidity_imbalance([uint256(0), uint256(0), _amount, uint256(0)], _swusd);
                deposit();
            } else {
                ISwerveFi(swerve).remove_liquidity_one_coin(_swusd, 2, 0);
            }
            _amount = IERC20(want).balanceOf(address(this));
        }
        
        address vault = Controller(controller).vaults(address(want));
        require(vault != address(0), "!vault");
        IERC20(want).safeTransfer(vault, _amount);
    }
    
    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        uint _flamswusd = IERC20(flamswusd).balanceOf(address(this));
        Vault(flamswusd).withdraw(_flamswusd);
        uint _swusd = IERC20(swusd).balanceOf(address(this));
        IERC20(swusd).safeApprove(swerve, 0);
        IERC20(swusd).safeApprove(swerve, _swusd);
        ISwerveFi(swerve).remove_liquidity_one_coin(_swusd, 2, 0);
        balance = IERC20(want).balanceOf(address(this));
        address vault = Controller(controller).vaults(address(want));
        require(vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(vault, balance);
    }
    
    function balanceOf() public view returns (uint) {
        uint _flamswusd = IERC20(flamswusd).balanceOf(address(this));
        uint _swusd = _flamswusd.mul(Vault(flamswusd).priceE18()).div(1e18);
        _swusd = IERC20(swusd).balanceOf(address(this)).add(_swusd);
        uint _usdt = ISwerveFi(swerve).calc_withdraw_one_coin(_swusd, 2);
        _usdt = IERC20(usdt).balanceOf(address(this)).add(_usdt);
        return _usdt;
    }
    
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }
    
    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
}