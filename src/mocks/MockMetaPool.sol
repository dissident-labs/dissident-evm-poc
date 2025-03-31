// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import "../interfaces/IMetaPool.sol";
import "./MockERC20.sol";

contract MockMetaPool is IMetaPool {
    mapping(address => uint256) public override stakedBalances;
    MockERC20 public immutable storyToken;
    
    constructor(address _storyToken) {
        storyToken = MockERC20(_storyToken);
    }
    
    function stake() external payable override {
        require(msg.value > 0, "Invalid amount");
        stakedBalances[msg.sender] += msg.value;
        storyToken.mint(msg.sender, msg.value);
    }
    
    function unstake(uint256 amount) external override {
        require(stakedBalances[msg.sender] >= amount, "Insufficient balance");
        stakedBalances[msg.sender] -= amount;
        storyToken.burn(msg.sender, amount);
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "ETH transfer failed");
    }
    
    function claimRewards() external override {
        // No-op in mock
    }

    function mockReward(address user, uint256 amount) external {
        stakedBalances[user] += amount;
        storyToken.mint(user, amount);
    }

    receive() external payable {}
}
