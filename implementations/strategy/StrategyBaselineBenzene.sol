// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/Controller.sol";
import "../../interfaces/flamincome/Vault.sol";

import "./StrategyBaseline.sol";

contract StrategyBaselineBenzene is StrategyBaseline {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public recv;
    address public fwant;
    address public frecv;

    constructor(address _want, address _controller)
        public
        StrategyBaseline(_want, _controller)
    {
        recv = GetRecv();
        frecv = Controller(controller).vaults(recv);
        fwant = Controller(controller).vaults(want);
        require(recv != address(0), "!fwant");
        require(fwant != address(0), "!fwant");
        require(frecv != address(0), "!frecv");
    }

    function DepositToken(uint256 _amount) public virtual {
        Vault(recv).deposit(_amount);
    }

    function WithdrawToken(uint256 _amount) public virtual {
        Vault(recv).withdraw(_amount);
    }

    function GetRecv() public virtual view returns (address) {
        return Controller(controller).vaults(want);
    }

    function GetPriceE18OfRecvInWant() public virtual view returns (uint256) {
        return Vault(recv).priceE18();
    }

    function deposit() public override {
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            DepositToken(_want);
        }
        uint256 _frecv = IERC20(recv).balanceOf(address(this));
        if (_frecv > 0) {
            IERC20(recv).safeApprove(frecv, 0);
            IERC20(recv).safeApprove(frecv, _frecv);
            Vault(frecv).deposit(_frecv);
        }
    }

    function withdraw(IERC20 _asset)
        external
        override
        returns (uint256 balance)
    {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        require(recv != address(_asset), "recv");
        require(frecv != address(_asset), "frecv");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    function withdraw(uint256 _amount) external override {
        require(msg.sender == controller, "!controller");
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want < _amount) {
            _amount = _amount.sub(_want);
            _amount = _amount.mul(1e18).div(GetPriceE18OfRecvInWant());
            uint256 _recv = IERC20(recv).balanceOf(address(this));
            if (_recv < _amount) {
                _amount = _amount.sub(_recv);
                _amount = _amount.mul(1e18).div(Vault(frecv).priceE18());
                uint256 _frecv = IERC20(frecv).balanceOf(address(this));
                if (_frecv < _amount) {
                    _amount = _frecv;
                }
                Vault(fwant).withdraw(_amount);
                _amount = IERC20(recv).balanceOf(address(this));
            }
            WithdrawToken(_amount);
            _amount = IERC20(want).balanceOf(address(this));
        }
        IERC20(want).safeTransfer(fwant, _amount);
    }

    function withdrawAll() external override returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        uint256 _frecv = IERC20(frecv).balanceOf(address(this));
        if (_frecv > 0) {
            Vault(fwant).withdraw(_frecv);
        }
        uint256 _recv = IERC20(recv).balanceOf(address(this));
        if (_recv > 0) {
            WithdrawToken(_recv);
        }
        balance = IERC20(want).balanceOf(address(this));
        IERC20(want).safeTransfer(fwant, balance);
    }

    function balanceOf() public override view returns (uint256) {
        uint256 _frecv = IERC20(frecv).balanceOf(address(this));
        uint256 _recv = IERC20(recv).balanceOf(address(this));
        uint256 _want = IERC20(want).balanceOf(address(this));
        _frecv = Vault(frecv).priceE18().mul(_frecv).div(1e18);
        _recv = _recv.add(_frecv);
        _recv = GetPriceE18OfRecvInWant().mul(_recv).div(1e18);
        return _want.add(_recv);
    }
}
