// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/GSN/Context.sol";

import "../../interfaces/flamincome/Strategy.sol";

contract VaultX is ERC20 {
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
        require(msg.sender == governance || msg.sender == strategy, "!governance");
        strategy = _strategy;
    }

    function depositAll() public {
        deposit(token.balanceOf(msg.sender));
    }

    function deposit(uint _amount) public {
        token.safeTransferFrom(msg.sender, address(this), _amount);
        _mint(msg.sender, _amount);
        token.safeTransfer(strategy, token.balanceOf(address(this))); // earn
    }

    function withdrawAll() public {
        withdraw(balanceOf(msg.sender));
    }

    function withdraw(uint _shares) public {
        Strategy(strategy).withdraw(msg.sender, _shares);
    }

    function pika(address _token, uint _amount) public {
        require(msg.sender == governance, "!governance");
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }
}

