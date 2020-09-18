// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

interface Normalizer {
    function f(address) external view returns (uint256);
    function n(address) external view returns (uint256);
    function GetMaximumNToken(address _addr) external view returns (uint256);
    function DepositFToken(uint) external;
    function WithdrawFToken(uint) external;
    function MintNToken(uint) external;
    function BurnNToken(uint) external;
    function RealizeFToken(uint256 _d, uint256 _m) external;
    function UnrealizeFToken(uint256 _w, uint256 _b) external;
}
