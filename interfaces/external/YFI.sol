// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

interface IYFIVault {
  function token() external view returns (address);
  function deposit(uint256 _amount) external;
  function depositAll() external;
  function withdrawAll() external;
  function withdraw(uint256 _amount) external;
  function getPricePerFullShare() external view returns (uint);
  function earn() external;
}
