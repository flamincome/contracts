// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/GSN/Context.sol";

import "../../interfaces/flamincome/Strategy.sol";

contract VaultY is ERC20 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    IERC20 public token;

    address public governance;
    address public strategy;

    constructor (address _token, address _strategy) public ERC20(
        string(abi.encodePacked("YIELD FLAMINCOME ", ERC20(_token).name())),
        string(abi.encodePacked("Y", ERC20(_token).symbol()))
    ) {
        _setupDecimals(ERC20(_token).decimals());
        token = IERC20(_token);
        governance = msg.sender;
        strategy = _strategy;
    }

    function balance() public view returns (uint) {
        return Strategy(strategy).balanceOfY();
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
        uint shares = 0;
        if (totalSupply() == 0) {
            shares = _amount;
        } else {
            shares = (_amount.mul(totalSupply())).div(balance());
        }
        _mint(msg.sender, shares);
        token.safeTransfer(strategy, token.balanceOf(address(this))); // earn
    }

    function withdrawAll() public {
        withdraw(balanceOf(msg.sender));
    }

    function withdraw(uint _shares) public {
        uint r = (balance().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);
        Strategy(strategy).withdraw(msg.sender, r);
    }

    function priceE18() public view returns (uint) {
        return balance().mul(1e18).div(totalSupply());
    }

    function pika(address _token, uint _amount) public {
        require(msg.sender == governance, "!governance");
        IERC20(_token).safeTransfer(governance, _amount);
    }
}
