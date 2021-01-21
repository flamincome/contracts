// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface BridgeVault {
    function deposit(uint) external;
}

interface StrategyLiquid {
    function want() external view returns (address);
    function nwant() external view returns (address);
    function liquid(uint) external;
}

contract StrategyBridge {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public governance;

    constructor() public {
        governance = msg.sender;
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function bridge(address _liquid, address _vault, uint256 _amount) public {
        address _nwant = StrategyLiquid(_liquid).nwant();
        address _want = StrategyLiquid(_liquid).want();

        IERC20(_nwant).safeTransferFrom(msg.sender, address(this), _amount);

        IERC20(_nwant).approve(_liquid, _amount);
        StrategyLiquid(_liquid).liquid(_amount);

        IERC20(_want).approve(_vault, _amount);
        BridgeVault(_vault).deposit(_amount);

        _amount = IERC20(_vault).balanceOf(address(this));
        IERC20(_vault).safeTransfer(msg.sender, _amount);
    }

    function pika(address _token, uint _amount) public {
        require(msg.sender == governance, "!governance");
        IERC20(_token).safeTransfer(governance, _amount);
    }
}

