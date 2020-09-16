// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

interface Normalizer {
    function flam(address) external view returns (uint256);
    function real(address) external view returns (uint256);
    function DepositFlamToken(uint) external;
    function WithdrawFlamToken(uint) external;
    function MintRealToken(uint) external;
    function BurnRealToken(uint) external;
}
