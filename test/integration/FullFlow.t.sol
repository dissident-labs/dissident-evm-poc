// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import "../Base.t.sol";

contract FullFlowTest is BaseTest {
    int24 constant TICK_LOWER = -100;
    int24 constant TICK_UPPER = 100;
    uint24 constant POOL_FEE = 3000;

    function setUp() public override {
        super.setUp();
    }

    function testFullStakingFlow() public {
        vm.startPrank(ALICE);
        uint256 amount = DEFAULT_AMOUNT;
        
        // 1. Deposit and stake
        storyToken.approve(address(dissident), amount);
        dissident.depositNative{value: amount}();
       dissident.stake(amount); 

        // 2. Wait and accumulate rewards
        metaPool.mockReward(ALICE, amount / 10); // 10% reward
        vm.warp(block.timestamp + 1 days);
        
        // 3. Compound rewards through staking manager
        dissident.autoCompound();

        // 4. Unstake 
        uint256 totalStaked = dissident.getStakedBalance(ALICE);
        dissident.unstake(totalStaked);
        
        //5. withdraw from vault
        dissident.withdraw(address(storyToken), totalStaked);

        // Verify final balance is greater than initial amount
        assertGt(storyToken.balanceOf(ALICE), INITIAL_BALANCE - amount);
        vm.stopPrank();
    }

    function testFullLiquidityFlow() public {
        vm.startPrank(ALICE);
        uint256 amount0 = DEFAULT_AMOUNT;
        uint256 amount1 = DEFAULT_AMOUNT;
        
        // 1. Deposit and provide liquidity
        token0.approve(address(dissident), amount0);
        token1.approve(address(dissident), amount1);
  
        
        /*(uint256 tokenId, ) = dissident.depositAndProvideLiquidity(
            address(token0),
            address(token1),
            POOL_FEE,
            amount0,
            amount1,
            TICK_LOWER,
            TICK_UPPER
        );
        
        // 2. Adjust position range through UniV3Manager
        address uniV3ManagerAddr = dissident.uniV3Manager();
        (bool success1,) = uniV3ManagerAddr.call(
            abi.encodeWithSignature(
                "adjustPositionRange(uint256,int24,int24)",
                tokenId,
                TICK_LOWER / 2,
                TICK_UPPER / 2
            )
        );
        require(success1, "adjustPositionRange failed");
        
        // 3. Remove partial liquidity
        (bool success2,) = uniV3ManagerAddr.call(
            abi.encodeWithSignature(
                "removeLiquidity(uint256,uint128)",
                tokenId,
                5e17 // Remove 50%
            )
        );
        require(success2, "removeLiquidity 50% failed");
        
        // 4. Remove remaining liquidity
        (bool success3,) = uniV3ManagerAddr.call(
            abi.encodeWithSignature(
                "removeLiquidity(uint256,uint128)",
                tokenId,
                1e18 // Remove 100%
            )
        );
        require(success3, "removeLiquidity 100% failed");
        
        // Verify tokens were returned to vault
        assertGt(dissident.getTokenBalance(ALICE, address(token0)), 0);
        assertGt(dissident.getTokenBalance(ALICE, address(token1)), 0);
 */       vm.stopPrank();
    }

    function testCombinedStakingAndLiquidity() public {
        vm.startPrank(ALICE);
        uint256 stakingAmount = DEFAULT_AMOUNT;
        uint256 liquidityAmount = DEFAULT_AMOUNT / 2;
        
        // 1. Deposit and stake Story tokens
        storyToken.approve(address(dissident), stakingAmount);
        dissident.depositNative{value: stakingAmount}();
        dissident.stake(stakingAmount);
        
        // 2. Provide liquidity with other tokens
        token0.approve(address(dissident), liquidityAmount);
        token1.approve(address(dissident), liquidityAmount);
       /* 
        (uint256 tokenId, ) = dissident.depositAndProvideLiquidity(
            address(token0),
            address(token1),
            POOL_FEE,
            liquidityAmount,
            liquidityAmount,
            TICK_LOWER,
            TICK_UPPER
        );
        
        // 3. Accumulate staking rewards
        metaPool.mockReward(ALICE, stakingAmount / 10);
        vm.warp(block.timestamp + 1 days);
        dissident.autoCompound();
        
        // 4. Remove liquidity
        address uniV3ManagerAddr = dissident.uniV3Manager();
        (bool success,) = uniV3ManagerAddr.call(
            abi.encodeWithSignature(
                "removeLiquidity(uint256,uint128)",
                tokenId,
                1e18
            )
        );
        require(success, "removeLiquidity failed");
        
        // 5. Unstake everything
        uint256 totalStaked = dissident.getStakedBalance(ALICE);
        dissident.unstake(totalStaked);
        dissident.withdraw(address(storyToken), totalStaked);
        

        // Verify final states
        assertGt(storyToken.balanceOf(ALICE), INITIAL_BALANCE - stakingAmount);
        assertGt(token0.balanceOf(ALICE), INITIAL_BALANCE - liquidityAmount);
        assertGt(token1.balanceOf(ALICE), INITIAL_BALANCE - liquidityAmount);
*/        vm.stopPrank();
    }
}
