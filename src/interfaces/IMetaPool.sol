// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

interface IMetaPool {
    function stake() external payable;
    function unstake(uint256 amount) external;
    function claimRewards() external;
    function stakedBalances(address user) external view returns (uint256);
}
