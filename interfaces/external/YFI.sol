// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

interface YFIVault {
  function deposit(uint256 _amount) external;
  function withdraw(uint256 _amount) external;
  function getPricePerFullShare() external view returns (uint);
}
