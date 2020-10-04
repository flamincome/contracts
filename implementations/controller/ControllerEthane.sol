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
        strategies[_token].push(_strategy);
    }

    function RemoveStrategy(address _token, address _strategy) public {
        require(msg.sender == governance, "!governance");

        address[] storage _tokenStrategies = strategies[_token];

        for (uint i = 0; i < _tokenStrategies.length - 1; i++)
            if (_tokenStrategies[i] == _strategy) {
                _tokenStrategies[i] = _tokenStrategies[_tokenStrategies.length - 1];

                _tokenStrategies.pop();
                Strategy(_strategy).withdrawAll();
                break;
            }
    }

    function SetDefaultDepositStrategy(address _token, address _strategy)
        public
    {
        require(msg.sender == governance, "!governance");
        default_deposit_strategy[_token] = _strategy;
    }

    function SetDefaultWithdrawStrategy(address _token, address _strategy)
        public
    {
        require(msg.sender == governance, "!governance");
        default_withdraw_strategy[_token] = _strategy;
    }

    function DepositTokenByNE18(address _token, uint256 _ne18) public {
        require(msg.sender == strategist, "!strategist");
        uint256 _depositAmount = IERC20(_token).balanceOf(address(this)).mul(_ne18).div(1e18);
        DepositTokenByAmount(_token, _depositAmount);
    }

    function DepositTokenByAmount(address _token, uint256 _amount) internal {
        address _strategy = default_deposit_strategy[_token];
        IERC20(_token).safeTransfer(_strategy, _amount);
        Strategy(_strategy).deposit();
    }

    function WithdrawTokenByNE18(address _token, uint256 _ne18) public {
        require(msg.sender == strategist, "!strategist");
        uint256 _withdrawAmount = GetBalance(_token).mul(_ne18).div(1e18);
        WithdrawTokenByAmount(_token, _withdrawAmount);
    }

    function WithdrawChain(address _token, address _default_withdraw_strategy, uint256 _amount) internal {
        address[] memory _tokenStrategies = strategies[_token];

        for (uint i = 0; i < _tokenStrategies.length; i++) {
            address _strategy = _tokenStrategies[i];
            if (_strategy == _default_withdraw_strategy) continue;

            uint256 _balance = Strategy(_strategy).balanceOf();
            if (_balance >= _amount) {
                Strategy(_strategy).withdraw(_amount);
                break;
            } else {
                Strategy(_strategy).withdraw(_balance);
                _amount = _amount.sub(_balance);
            }
        }
    }

    function WithdrawTokenByAmount(address _token, uint256 _amount) internal {
        uint256 _remain = IERC20(_token).balanceOf(address(this));
        if (_remain >= _amount) {
            IERC20(_token).safeTransfer(vaults[_token], _amount);
        } else {
            IERC20(_token).safeTransfer(vaults[_token], _remain);
            uint256 _left = _amount.sub(_remain);

            address _strategy = default_withdraw_strategy[_token];
            uint256 _balance = Strategy(_strategy).balanceOf();
            if (_balance >= _left) {
                Strategy(_strategy).withdraw(_left);
            } else {
                Strategy(_strategy).withdraw(_balance);
                WithdrawChain(_token, _strategy, _left.sub(_balance));
            }
        }
    }

    function GetBalance(address _token) public view returns (uint256) {
        address[] memory _tokenStrategies = strategies[_token];

        uint256 _totalBalance = IERC20(_token).balanceOf(address(this));

        for (uint i = 0; i < _tokenStrategies.length; i++) {
            address _strategy = _tokenStrategies[i];
            uint256 _balance = Strategy(_strategy).balanceOf();
            _totalBalance = _totalBalance.add(_balance);
        }
        return _totalBalance;
    }

    function earn(address _token, uint256 _amount) public {
        require(msg.sender == vaults[_token], "!vault");
        DepositTokenByAmount(_token, _amount);
    }

    function balanceOf(address _token) external view returns (uint256) {
        return GetBalance(_token);
    }

    function withdraw(address _token, uint256 _amount) public {
        require(msg.sender == vaults[_token], "!vault");
        WithdrawTokenByAmount(_token, _amount);
    }
}
