// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

interface IVaultX {
    function token() external view returns (address);
    function setStrategy(address _strategy) external;
}
