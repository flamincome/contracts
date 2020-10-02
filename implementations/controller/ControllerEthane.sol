// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../../interfaces/flamincome/Strategy.sol";

contract ControllerEthane {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public governance;
    address public strategist;
    address public rewards;

    mapping(address => address) public vaults;
    mapping(address => address) public default_deposit_strategy;
    mapping(address => address) public default_withdraw_strategy;
    mapping(address => address[]) public strategies;

    constructor() public {
        governance = msg.sender;
        strategist = msg.sender;
        rewards = msg.sender;
    }

    function SetRewards(address _rewards) public {
        require(msg.sender == governance, "!governance");
        rewards = _rewards;
    }

    function SetStrategist(address _strategist) public {
        require(msg.sender == governance, "!governance");
        strategist = _strategist;
    }

    function SetGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function SetVault(address _token, address _vault) public {
        require(msg.sender == governance, "!governance");
        vaults[_token] = _vault;
    }

    function AddStrategy(address _token, address _strategy) public {
        // TODO: IMPL
        // require(msg.sender == strategist || msg.sender == governance, "!strategist");
        // address _current = strategies[_token];
        // if (_current != address(0)) {
        //    Strategy(_current).withdrawAll();
        // }
        // strategies[_token] = _strategy;
    }

    function RemoveStrategy(address _token, address _strategy) public {
        // TODO: IMPL
        // require(msg.sender == strategist || msg.sender == governance, "!strategist");
        // address _current = strategies[_token];
        // if (_current != address(0)) {
        //    Strategy(_current).withdrawAll();
        // }
        // strategies[_token] = _strategy;
    }

    function SetDefaultDepositStrategy(address _token, address _strategy)
        public
    {
        // TODO: IMPL
        // require(msg.sender == strategist || msg.sender == governance, "!strategist");
        // address _current = strategies[_token];
        // if (_current != address(0)) {
        //    Strategy(_current).withdrawAll();
        // }
        // strategies[_token] = _strategy;
    }

    function SetDefaultWithdrawStrategy(address _token, address _strategy)
        public
    {
        // TODO: IMPL
        // require(msg.sender == strategist || msg.sender == governance, "!strategist");
        // address _current = strategies[_token];
        // if (_current != address(0)) {
        //    Strategy(_current).withdrawAll();
        // }
        // strategies[_token] = _strategy;
    }

    function DepositTokenByNE18(address _token, uint256 _ne18) public {
        // TODO: IMPL
        // address _strategy = strategies[_token];
        // address _want = Strategy(_strategy).want();
        // IERC20(_token).safeTransfer(_strategy, _amount);
        // Strategy(_strategy).deposit();
    }

    function DepositTokenByAmount(address _token, uint256 _amount) public {
        // TODO: IMPL
        // address _strategy = strategies[_token];
        // address _want = Strategy(_strategy).want();
        // IERC20(_token).safeTransfer(_strategy, _amount);
        // Strategy(_strategy).deposit();
    }

    function WithdrawTokenByNE18(address _token, uint256 _ne18) public {
        // TODO: IMPL
        // address _strategy = strategies[_token];
        // address _want = Strategy(_strategy).want();
        // IERC20(_token).safeTransfer(_strategy, _amount);
        // Strategy(_strategy).deposit();
    }

    function WithdrawTokenByAmount(address _token, uint256 _ne18) public {
        // TODO: IMPL
        // address _strategy = strategies[_token];
        // address _want = Strategy(_strategy).want();
        // IERC20(_token).safeTransfer(_strategy, _amount);
        // Strategy(_strategy).deposit();
    }

    function GetBalance(address _token) public view returns (uint256) {
        // TODO: IMPL
        // return Strategy(strategies[_token]).balanceOf();
    }

    function earn(address _token, uint256 _amount) public {
        DepositToken(_token, 1e18);
    }

    function balanceOf(address _token) external view returns (uint256) {
        return GetBalance(_token);
    }

    function withdraw(address _token, uint256 _amount) public {
        WithdrawTokenByAmount(_token, _amount);
    }
}
