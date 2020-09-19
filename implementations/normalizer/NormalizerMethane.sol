// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/GSN/Context.sol";

import "../../interfaces/flamincome/Vault.sol";

contract NormalizerMethane is ERC20 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    IERC20 public underlying;
    mapping(address => uint256) public f;
    mapping(address => uint256) public n;
    address public governance;
    uint256 public overfillE18;

    constructor(address _token)
        public
        ERC20(
            string(
                abi.encodePacked(
                    "normalized ",
                    ERC20(Vault(_token).token()).name()
                )
            ),
            string(abi.encodePacked("n", ERC20(Vault(_token).token()).symbol()))
        )
    {
        _setupDecimals(ERC20(_token).decimals());
        underlying = IERC20(_token);
        governance = msg.sender;
        overfillE18 = 0;
    }

    function GetMaximumNToken(address _addr) public view returns (uint256) {
        uint256 _val = f[_addr].mul(Vault(address(underlying)).priceE18()).div(
            1e18
        );
        uint256 _over = _val.mul(overfillE18).div(1e18);
        return _val.sub(_over);
    }

    function DepositFToken(uint256 _amount) public {
        f[msg.sender] = f[msg.sender].add(_amount);
        underlying.safeTransferFrom(msg.sender, address(this), _amount);
    }

    function WithdrawFToken(uint256 _amount) public {
        f[msg.sender] = f[msg.sender].sub(_amount);
        require(n[msg.sender] <= GetMaximumNToken(msg.sender), "insufficient");
        underlying.safeTransfer(msg.sender, _amount);
    }

    function MintNToken(uint256 _amount) public {
        n[msg.sender] = n[msg.sender].add(_amount);
        require(n[msg.sender] <= GetMaximumNToken(msg.sender), "insufficient");
        _mint(msg.sender, _amount);
    }

    function BurnNToken(uint256 _amount) public {
        n[msg.sender] = n[msg.sender].sub(_amount);
        _burn(msg.sender, _amount);
    }

    function RealizeFToken(uint256 _d, uint256 _m) external {
        DepositFToken(_d);
        MintNToken(_m);
    }

    function UnrealizeFToken(uint256 _w, uint256 _b) external {
        BurnNToken(_b);
        WithdrawFToken(_w);
    }

    function SetGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function SetOverfillE18(uint256 _overfillE18) external {
        require(msg.sender == governance, "!governance");
        require(_overfillE18 < 1e18, "wrong value");
        overfillE18 = _overfillE18;
    }
}
