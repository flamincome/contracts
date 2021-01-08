// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/GSN/Context.sol";

import "../../interfaces/flamincome/Strategy.sol";

contract VaultBaselineX is ERC20 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    IERC20 public token;

    address public governance;
    address public strategy;

    constructor (address _token, address _strategy) public ERC20(
        string(abi.encodePacked("CROSS FLAMINCOME ", ERC20(_token).name())),
        string(abi.encodePacked("X", ERC20(_token).symbol()))
    ) {
        _setupDecimals(ERC20(_token).decimals());
        token = IERC20(_token);
        governance = msg.sender;
        strategy = _strategy;
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setStrategy(address _strategy) public {
        require(msg.sender == governance, "!governance");

        if (strategy != address(0)) {
           Strategy(strategy).withdrawAll();
        }
        strategy = _strategy;
    }

    function earn() public {
        uint _bal = token.balanceOf(address(this));
        token.safeTransfer(strategy, _bal);
    }

    function depositAll() public {
        deposit(token.balanceOf(msg.sender));
    }

    function deposit(uint _amount) public {
        uint _before = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint _after = token.balanceOf(address(this));
        uint _shares = _after.sub(_before); // Additional check for deflationary tokens
        _mint(msg.sender, _shares);
        earn();
    }

    function withdrawAll() public {
        withdraw(balanceOf(msg.sender));
    }

    // No rebalance implementation for lower fees and faster swaps
    function withdraw(uint _shares) public {
        Strategy(strategy).withdraw(msg.sender, _shares);
    }

    function withdrawVault(address _token, uint _amount) public {
        require(msg.sender == governance, "!governance");
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }
}

