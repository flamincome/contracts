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
        require(msg.sender == governance, "!governance");
        require(msg.sender == strategist, "!strategist");

        address[] _tokenStrategies = strategies[_token];
        _tokenStrategies.push(_strategy);
    }

    function RemoveStrategy(address _token, address _strategy) public {
        require(msg.sender == governance, "!governance");
        require(msg.sender == strategist, "!strategist");

        address[] _tokenStrategies = strategies[_token];

        for (uint i = 0; i < _tokenStrategies.length - 1; i++)
            if (_tokenStrategies[i] == _strategy) {
                _tokenStrategies[i] = _tokenStrategies[_tokenStrategies.length - 1];
                break;
            }
        _tokenStrategies.length -= 1;
    }

    function SetDefaultDepositStrategy(address _token, address _strategy)
        public
    {
        require(msg.sender == governance, "!governance");
        require(msg.sender == strategist, "!strategist");

        address _current = default_deposit_strategy[_token];

        if (_current == _strategy) {
            return;
        }

        if (_current != address(0)) {
           Strategy(_current).withdrawAll();
        }

        default_deposit_strategy[_token] = _strategy;
    }

    function SetDefaultWithdrawStrategy(address _token, address _strategy)
        public
    {
        require(msg.sender == governance, "!governance");
        require(msg.sender == strategist, "!strategist");

        address _current = default_withdraw_strategy[_token];

        if (_current == _strategy) return;

        if (_current != address(0)) {
           Strategy(_current).withdrawAll();
        }

         default_withdraw_strategy[_token] = _strategy;
    }

    function DepositTokenByNE18(address _token, uint256 _ne18) public {
        uint256 _depositAmount = IERC20(_token).balanceOf(address(this)).mul(_ne18).div(1e18);
        DepositTokenByAmount(_token, _depositAmount);
    }

    function DepositTokenByAmount(address _token, uint256 _amount) public {
        address _strategy = default_deposit_strategy[_token];

        if (_strategy == address(0)) return;

        address _want = Strategy(_strategy).want();
        if (_want == _token) {
            IERC20(_token).safeTransfer(_strategy, _amount);
        }
        Strategy(_strategy).deposit();
    }

    function WithdrawTokenByNE18(address _token, uint256 _ne18) public {
        uint256 _withdrawAmount = balanceOf().mul(_ne18).div(1e18);
        WithdrawTokenByAmount(_token, _withdrawAmount);
    }

    // FIXME: need to withdraw from another strategy if default one is empty
    function WithdrawTokenByAmount(address _token, uint256 _amount) public {
        require(msg.sender == vaults[_token], "!vault");

        address _strategy = default_withdraw_strategy[_token];

        if (_strategy == address(0)) return;

        Strategy(strategies[_token]).withdraw(_amount);
    }

    function GetBalance(address _token) public view returns (uint256) {
        address[] _tokenStrategies = strategis[_token];

        uint256 _totalBalance = 0;

        for (uint i = 0; i < _tokenStrategies.length - 1; i++) {
            address _strategy = _tokenStrategies;
            uint256 _balance = Strategy(_strategy).balanceOf();
            _totalBalance += _balance;
        }
        return _totalBalance;
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
