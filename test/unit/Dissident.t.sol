// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import "../Base.t.sol";

contract DissidentTest is BaseTest {
    int24 constant TICK_LOWER = -100;
    int24 constant TICK_UPPER = 100;
    uint24 constant POOL_FEE = 3000;

    function setUp() public override {
        super.setUp();
        
        // Initialize with proper permissions
        vm.startPrank(OWNER);
        vm.stopPrank();
        
        // Setup token approvals and balances
        deal(address(token0), ALICE, 1000000e18);
        deal(address(token1), ALICE, 1000000e18);
        
        vm.startPrank(ALICE);
        token0.approve(address(dissident), type(uint256).max);
        token1.approve(address(dissident), type(uint256).max);
        vm.stopPrank();
    }

    function testStake() public {
        uint256 amount = 1 ether;
        
        vm.startPrank(ALICE);
        // First deposit native tokens
        dissident.depositNative{value: amount}();
        
        // Then stake
        dissident.stake(amount);
        
        assertEq(dissident._userStakes(ALICE), amount);
        assertEq(metaPool.stakedBalances(address(dissident)), amount);
        assertEq(dissident.getNativeBalance(ALICE), 0); 
        vm.stopPrank();
    }

    function testUnstake() public {
        uint256 amount = 1 ether;
        
        vm.startPrank(ALICE);
        // First stake
        dissident.depositNative{value: amount}();
        dissident.stake(amount);
      
        // Then unstake
        dissident.unstake(amount);
        
        assertEq(dissident._userStakes(ALICE), 0);
        assertEq(metaPool.stakedBalances(ALICE), 0);
        vm.stopPrank();
    }

    function testAutoCompound() public {
        vm.startPrank(ALICE);
        uint256 amount = 1 ether;
        
        // Stake ETH
        dissident.depositNative{value: amount}();
        dissident.stake(amount);
        
        // Mock some rewards
        metaPool.mockReward(ALICE, 0.1 ether);
        
        // Advance time
        vm.warp(block.timestamp + 1 days);
        
        // Compound rewards
        dissident.autoCompound();
        
        // Check increased stake
        assertGt(dissident.getStakedBalance(ALICE), amount);
        vm.stopPrank();
    }

    function test_RevertWhen_StakeZero() public {
        vm.expectRevert("Invalid amount");
        dissident.stake(0);
    }

    function test_RevertWhen_StakeInsufficientBalance() public {
        uint256 amount = 1 ether;
        
        vm.startPrank(ALICE);
        vm.expectRevert("Insufficient balance");
        dissident.stake(amount); // Try to stake without depositing first
        vm.stopPrank();
    }

    function test_RevertWhen_UnstakeMoreThanStaked() public {
        uint256 amount = 1 ether;
        
        vm.startPrank(ALICE);
        dissident.depositNative{value: amount}();
        dissident.stake(amount);
        
        vm.expectRevert("Insufficient stake");
        dissident.unstake(amount + 1);
        vm.stopPrank();
    }

    function testDepositAndStake() public {
        uint256 amount = 1 ether;
        
        vm.startPrank(ALICE);

        uint256 initialStoryTokenBalance = storyToken.balanceOf(ALICE);

        dissident.depositNative{value: amount}();
        dissident.stake(amount);
       
        assertEq(dissident.userStakes(ALICE), amount);
        assertEq(storyToken.balanceOf(ALICE), initialStoryTokenBalance);
        vm.stopPrank();
    }

    function testUnstakeAndWithdraw() public {
      vm.startPrank(ALICE);
      uint256 amount = DEFAULT_AMOUNT;

      uint256 storyTokenBalance = storyToken.balanceOf(ALICE);

      // Setup: deposit and stake
      dissident.depositNative{value: amount}();
      dissident.stake(amount);

      // Test unstake and withdraw
      dissident.unstake(amount);
      dissident.withdrawNative(amount);

      assertEq(dissident.getStakedBalance(ALICE), 0);
      assertEq(storyToken.balanceOf(ALICE), storyTokenBalance);
      assertEq(ALICE.balance, amount);
      vm.stopPrank();
    }

    function testDepositAndProvideLiquidity() public {
        vm.startPrank(ALICE);
        uint256 amount0 = DEFAULT_AMOUNT;
        uint256 amount1 = DEFAULT_AMOUNT;
        
        token0.approve(address(dissident), amount0);
        token1.approve(address(dissident), amount1);
 
        /*
        (uint256 tokenId, uint128 liquidity) = dissident.depositAndProvideLiquidity(
            address(token0),
            address(token1),
            POOL_FEE,
            amount0,
            amount1,
            TICK_LOWER,
            TICK_UPPER
        );
        
        assertTrue(tokenId > 0);
        assertTrue(liquidity > 0);
        */vm.stopPrank();
    }

    function testCreatePosition() public {
        vm.startPrank(ALICE);
        uint256 amount0 = 1 wei;
        uint256 amount1 = 1 wei;
        
        // First deposit tokens
        token0.approve(address(dissident), amount0);
        token1.approve(address(dissident), amount1);
        dissident.deposit(address(token0), amount0);
        dissident.deposit(address(token1), amount1);
        
        // Create position through UniV3Manager
        (uint256 tokenId, uint128 liquidity) = dissident.addLiquidity(
            address(token0),
            address(token1),
            POOL_FEE,
            amount0,
            amount1,
            TICK_LOWER,
            TICK_UPPER
        );
        
        // Verify position was created
        (IDissident.Position memory position, ) = dissident.findPosition(ALICE, tokenId);
        assertEq(position.tokenId, tokenId);
       // assertEq(position.liquidity, liquidity);
       // assertEq(position.token0, address(token0));
        //assertEq(position.token1, address(token1));
        //assertEq(position.tickLower, TICK_LOWER);
        //assertEq(position.tickUpper, TICK_UPPER);
        //assertEq(uint8(position.token0Type), uint8(IDissident.TokenType.ERC20));
        //assertEq(uint8(position.token1Type), uint8(IDissident.TokenType.ERC20));
        vm.stopPrank();
    }

    function testDepositNative() public {
        uint256 amount = 1 ether;
        
        vm.startPrank(ALICE);
        dissident.depositNative{value: amount}();
        
        assertEq(dissident.getNativeBalance(ALICE), amount);
        assertEq(address(dissident).balance, amount);
        vm.stopPrank();
    }

    function test_RevertWhen_DepositNativeZero() public {
        vm.startPrank(ALICE);
        vm.expectRevert("Invalid amount");
        dissident.depositNative{value: 0}();
        vm.stopPrank();
    }

    function test_RevertWhen_DepositZero() public {
        // Pass amount parameter
        vm.expectRevert("Invalid amount");
        dissident.depositNative{value: 0}();
    }

    function test_RevertWhen_WithdrawZero() public {
        vm.prank(ALICE);
        vm.expectRevert("Invalid amount");
        dissident.withdraw(address(storyToken), 0);
    }
    
    function test_RevertWhen_WithdrawNativeZero() public {
        vm.prank(ALICE);
        vm.expectRevert("Invalid amount");
        dissident.withdraw(address(storyToken), 0);
    }

    function test_RevertWhen_DepositAndProvideLiquidityZero() public {
        vm.prank(ALICE);
        vm.expectRevert("Invalid amount");
        dissident.deposit(address(token0), 0);
        vm.expectRevert("Invalid amount");
        dissident.deposit(address(token1), 0);

        vm.expectRevert("No liquidity added");
        dissident.addLiquidity(
            address(token0),
            address(token1),
            POOL_FEE,
            0,
            0,
            TICK_LOWER,
            TICK_UPPER
        );
    }

    function testPause() public {
        vm.startPrank(dissident.owner());
        vm.deal(dissident.owner(), 100 ether);
        vm.deal(ALICE, 100 ether);

        dissident.pause();
        
        vm.expectRevert("Pausable: paused");
        dissident.depositNative{value: 1 ether}();

        dissident.unpause();
        vm.deal(dissident.owner(), 0);
        vm.stopPrank();
        
        // Should work after unpause
        vm.prank(ALICE);
        dissident.depositNative{value: 1 ether}();
        assertEq(dissident.getNativeBalance(ALICE), 1 ether);

    }
}
