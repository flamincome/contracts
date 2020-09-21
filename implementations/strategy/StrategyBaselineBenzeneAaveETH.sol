// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/flamincome/Controller.sol";
import "../../interfaces/flamincome/Vault.sol";
import "../../interfaces/external/Aave.sol";
import "../../interfaces/external/WETH.sol";

import "./StrategyBaselineBenzene.sol";

contract StrategyBaselineBenzeneAaveETH is StrategyBaselineBenzene {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant weth = address(
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    );

    address public constant aeth = address(
        0x3a3A65aAb0dd2A17E3F1947bA16138cd37d08c04
    );
    address public constant provider = address(
        0x24a42fD28C976A61Df5D00D0599C34c4f90748c8
    );
    address public constant eth = address(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );

    constructor(address _controller)
        public
        StrategyBaselineBenzene(weth, _controller)
    {
        SetRecv(aeth);
    }

    function DepositToken(uint256 _amount) internal override {
        IWETH(want).withdraw(_amount);
        address pool = ILendingPoolAddressesProvider(provider).getLendingPool();
        require(pool != address(0), "!pool");
        ILendingPool(pool).deposit{value: _amount}(eth, _amount, 0);
    }

    function WithdrawToken(uint256 _amount) internal override {
        IAaveToken(aeth).redeem(_amount);
        IWETH(want).deposit{value: _amount}();
    }

    function GetPriceE18OfRecvInWant() public override view returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}
