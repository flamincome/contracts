// SPDX-License-Identifier: MIT

pragma solidity >0.7.0;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

interface AaveStrat {
    function safeWithdraw(uint256 _amount) external;
    function pika(IERC20 _asset, uint256 _amount) external;
    function update(address _newStratrgy) external;
    function setGovernance(address _governance) external;
}

interface NewStrat {
    function D(uint256 _ne18) external;
    function setGovernance(address _governance) external;
}

contract MigrateStrat {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    AaveStrat currentStrategy = AaveStrat(0x5D6DF808Be06d77c726001b1B3163C3294cb8D08);
    address nextStrategy = 0xb8d6471cA573C92c7096Ab8600347F6a9Fe268a5;
    IERC20 aUSDT = IERC20(0x3Ed3B47Dd13EC9a98b44e6204A523E766B225811);
    IERC20 USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address dao = 0x4B827D771456Abd5aFc1D05837F915577729A751;
    uint tenMil = 10e12;

    function migrate() public {
        uint aUSDTonOldStrat = aUSDT.balanceOf(address(currentStrategy));
        while (aUSDTonOldStrat > tenMil){
            currentStrategy.safeWithdraw(tenMil);
            currentStrategy.pika(USDT, tenMil);
            uint usdtOwned = USDT.balanceOf(address(this));
            USDT.safeTransfer(nextStrategy, usdtOwned);
            NewStrat(nextStrategy).D(1e18-1);
            aUSDTonOldStrat = aUSDT.balanceOf(address(currentStrategy));
        }
        currentStrategy.update(nextStrategy);
        currentStrategy.setGovernance(dao);
        NewStrat(nextStrategy).setGovernance(dao);
    }

    function returnGovernanceOldStrat() public {
        currentStrategy.setGovernance(dao);
    }

    function returnGovernanceNewStrat() public {
        NewStrat(nextStrategy).setGovernance(dao);
    }
}
