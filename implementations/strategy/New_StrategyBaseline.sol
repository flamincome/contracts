// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/Controller.sol";

abstract contract StrategyBaseline {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public want;
    address public governance;
    address public vaultX;
    address public vaultY;

    constructor(address _want, address _controller) public {
        governance = msg.sender;
        want = _want;
    }

    function deposit() public virtual;

    function withdraw(IERC20 _asset) external virtual returns (uint256 balance);

    function withdraw(uint256 _amount) external virtual;

    function withdrawAll() external virtual returns (uint256 balance);

    function balanceOf() public virtual view returns (uint256);

    function SetGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setVaultX(address _vaultX) public {
        require(msg.sender == governance, "!governance");
        vaultX = _vaultX;
    }

    function setVaultY(address _vaultY) public {
        require(msg.sender == governance, "!governance");
        vaultY = _vaultY;
    }
}
