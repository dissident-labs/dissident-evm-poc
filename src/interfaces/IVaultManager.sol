// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

interface IVaultManager {
    // Functions
    function deposit(address token, uint256 amount) external;
    function withdraw(address token, uint256 amount) external;
    function deductTokenBalance(address user, address token, uint256 amount) external;
    function deductNativeBalance(address user, uint256 amount) external;
    function creditTokenBalance(address user, address token, uint256 amount) external;
    function creditNativeBalance(address user, uint256 amount) external;
    function getTokenBalance(address user, address token) external view returns (uint256);
    function getNativeBalance(address user) external view returns (uint256);
    function setManager(address manager, bool authorized) external;
}
