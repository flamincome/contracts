// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/Controller.sol";

contract StrategyBaseline {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public want;
    address public governance;
    address public controller;

    constructor(address _want, address _controller) public {
        governance = msg.sender;
        controller = _controller;
        want = _want;
    }

    function DepositToken() public virtual {}

    function WithdrawToken(uint256 _amount) public virtual {}

    function WithdrawEx() public virtual {}

    function CheckEx(address _asset) public virtual {}

    function GetBalanceEx() public virtual pure returns (uint256) {
        return 0;
    }

    function deposit() public virtual {
        DepositToken();
    }

    function withdraw(address _asset)
        external
        returns (uint256 balance)
    {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        CheckEx(_asset);
        balance = IERC20(_asset).balanceOf(address(this));
        IERC20(_asset).safeTransfer(controller, balance);
    }

    function withdraw(uint256 _amount) external virtual {
        require(msg.sender == controller, "!controller");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            WithdrawToken(_amount.sub(_balance));
            _amount = IERC20(want).balanceOf(address(this));
        }
        address vault = Controller(controller).vaults(address(want));
        require(vault != address(0), "!vault");
        IERC20(want).safeTransfer(vault, _amount);
    }

    function withdrawAll() external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        address vault = Controller(controller).vaults(address(want));
        require(vault != address(0), "!vault");
        WithdrawEx();
        balance = IERC20(want).balanceOf(address(this));
        IERC20(want).safeTransfer(vault, balance);
    }

    function balanceOf() public view returns (uint256) {
        uint256 _want = IERC20(want).balanceOf(address(this));
        return GetBalanceEx().add(_want);
    }

    function SetGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function SetController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
}
