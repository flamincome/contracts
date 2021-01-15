// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/Controller.sol";
import "../../interfaces/flamincome/Vault.sol";

import "./StrategyBaselineAmmonia.sol";

contract StrategyBaselineAmmoniaBuffer is StrategyBaselineAmmonia {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public nwant;
    address public xvault;

    constructor(address _nwant, address _want, address _controller, address _xvault)
        public
        StrategyBaselineAmmonia(_want, _controller)
    {
        nwant = _nwant;
        xvault = _xvault;
    }

    function deposit() public override {
        require(msg.sender == controller, "!controller");
        uint amount = IERC20(want).balanceOf(address(this));
        IERC20(want).approve(xvault, amount);
        Vault(xvault).deposit(amount);
    }

    function liquid(uint256 _amount) public {
        uint _before = IERC20(want).balanceOf(address(this));
        IERC20(nwant).safeTransferFrom(msg.sender, address(this), _amount);
        Vault(xvault).withdraw(_amount);
        uint _after = IERC20(want).balanceOf(address(this));
        _amount = _after.sub(_before);
        IERC20(want).safeTransfer(msg.sender, _amount);
    }

    function balanceOf(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function balanceOf() public override view returns (uint256) {
        return balanceOf(xvault).add(balanceOf(nwant)).add(balanceOf(want));
    }

    function withdraw(uint256 _amount) external override {
        require(msg.sender == controller, "!controller");
        uint _before = IERC20(want).balanceOf(address(this));
        Vault(xvault).withdraw(_amount);
        uint _after = IERC20(want).balanceOf(address(this));
        _amount = _after.sub(_before);

        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault");

        IERC20(want).safeTransfer(_vault, _amount);
    }

    function pika(address _token, uint _amount) public {
        require(msg.sender == governance, "!governance");
        IERC20(_token).safeTransfer(governance, _amount);
    }
}

