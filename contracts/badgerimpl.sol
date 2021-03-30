// SPDX-License-Identifier: MIT

pragma solidity >0.7.0;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

interface S{
    function setGovernance(address) external;
    function pika(address, uint256) external;
    function executeVote(uint256) external;
}

contract MigHelper {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant token = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant atoken = 0x3Ed3B47Dd13EC9a98b44e6204A523E766B225811;
    address public constant target = 0x5D6DF808Be06d77c726001b1B3163C3294cb8D08;
    address public constant strategy = 0xb8d6471cA573C92c7096Ab8600347F6a9Fe268a5;
    address public constant gov = 0x4B827D771456Abd5aFc1D05837F915577729A751;
    address public constant vote = 0x24d840DbAa0c0c72589C8f8860063024d1C064Db;
    uint256 public constant id = 20;

    function DO() public {
        uint256 _amt = IERC20(atoken).balanceOf(target);
        _amt = _amt.sub(10000000);
        S(target).pika(atoken, _amt);
        _amt = IERC20(atoken).balanceOf(address(this));
        IERC20(atoken).safeTransfer(strategy, _amt);
        RET();
        S(vote).executeVote(id);
    }

    function RET() public {
        S(target).setGovernance(gov);
    }
}
