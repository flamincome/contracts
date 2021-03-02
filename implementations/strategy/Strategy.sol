// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/VaultX.sol";
import "../../interfaces/flamincome/VaultY.sol";

contract Strategy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public want;
    address public governance;
    address public vaultX;
    address public vaultY;

    uint256 public feexe18 = 5e15;
    uint256 public feeye18 = 5e15;
    uint256 public feepe18 = 5e16;

    constructor(address _want) public {
        governance = msg.sender;
        want = _want;
    }

    function deposit(uint256 _amount) public virtual {}

    function withdraw(address _to, uint256 _amount) public virtual {
        require(msg.sender == vaultX || msg.sender == vaultY, "!vault");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        _amount = Math.min(_balance, _amount);
        if (msg.sender == vaultX) {
            uint256 _fee = _amount.mul(feexe18).div(1e18);
            IERC20(want).safeTransfer(governance, _fee);
            IERC20(want).safeTransfer(_to, _amount.sub(_fee));
        }
        else if (msg.sender == vaultY) {
            uint256 _fee = _amount.mul(feeye18).div(1e18);
            IERC20(want).safeTransfer(governance, _fee);
            IERC20(want).safeTransfer(_to, _amount.sub(_fee));
        }
    }

    function update(address _newStratrgy) public virtual {
        require(msg.sender == governance, "!governance");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        IERC20(want).safeTransfer(_newStratrgy, _balance);
        IVaultX(vaultX).setStrategy(_newStratrgy);
        IVaultY(vaultY).setStrategy(_newStratrgy);
    }

    function balanceOfY() public view virtual returns (uint256) {
        return IERC20(want).balanceOf(address(this)).sub(IERC20(vaultX).totalSupply());
    }

    function pika(IERC20 _asset, uint256 _amount) public {
        require(msg.sender == governance, "!governance");
        _asset.safeTransfer(governance, _amount);
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setVaultX(address _vaultX) public {
        require(msg.sender == governance, "!governance");
        require(IVaultX(_vaultX).token() == want, "!vault");
        vaultX = _vaultX;
    }

    function setVaultY(address _vaultY) public {
        require(msg.sender == governance, "!governance");
        require(IVaultY(_vaultY).token() == want, "!vault");
        vaultY = _vaultY;
    }

    function setFeeXE18(uint256 _fee) public {
        require(msg.sender == governance, "!governance");
        feexe18 = _fee;
    }

    function setFeeYE18(uint256 _fee) public {
        require(msg.sender == governance, "!governance");
        feeye18 = _fee;
    }

    function setFeePE18(uint256 _fee) public {
        require(msg.sender == governance, "!governance");
        feepe18 = _fee;
    }
}
