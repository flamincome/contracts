// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

interface IAave {
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external;
}

interface ILendingPoolAddressesProvider {
    function getLendingPool() external view returns (address);
    function getLendingPoolCore() external view returns (address);
    function getPriceOracle() external view returns (address);
}

interface ILendingPool {
    function deposit(address, uint256, uint16) external payable;
}

interface IAaveToken {
    function redeem(uint256) external;
}

interface Aave {
    function borrow(address _reserve, uint _amount, uint _interestRateModel, uint16 _referralCode) external;
    function setUserUseReserveAsCollateral(address _reserve, bool _useAsCollateral) external;
    function repay(address _reserve, uint _amount, address payable _onBehalfOf) external payable;
    function getUserAccountData(address _user)
        external
        view
        returns (
            uint totalLiquidityETH,
            uint totalCollateralETH,
            uint totalBorrowsETH,
            uint totalFeesETH,
            uint availableBorrowsETH,
            uint currentLiquidationThreshold,
            uint ltv,
            uint healthFactor
        );
    function getUserReserveData(address _reserve, address _user)
        external
        view
        returns (
            uint currentATokenBalance,
            uint currentBorrowBalance,
            uint principalBorrowBalance,
            uint borrowRateMode,
            uint borrowRate,
            uint liquidityRate,
            uint originationFee,
            uint variableBorrowIndex,
            uint lastUpdateTimestamp,
            bool usageAsCollateralEnabled
        );
}



interface AaveToken {
    function underlyingAssetAddress() external view returns (address);
}

interface Oracle {
    function getAssetPrice(address reserve) external view returns (uint);
    function latestAnswer() external view returns (uint);
}
