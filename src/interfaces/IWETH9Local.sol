// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

/// @title Interface for WETH9
interface IWETH9Local {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}