// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/Math.sol";
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

    function deposit() public virtual {}

    function withdraw(IERC20 _asset)
        external
        virtual
        returns (uint256 balance)
    {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    function withdraw(uint256 _amount) external virtual {
        require(msg.sender == controller, "!controller");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        _amount = Math.min(_balance, _amount);
        address vault = Controller(controller).vaults(address(want));
        require(vault != address(0), "!vault");
        IERC20(want).safeTransfer(vault, _amount);
    }

    function withdrawAll() external virtual returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        balance = IERC20(want).balanceOf(address(this));
        address vault = Controller(controller).vaults(address(want));
        require(vault != address(0), "!vault");
        IERC20(want).safeTransfer(vault, balance);
    }

    function balanceOf() public virtual view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
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
