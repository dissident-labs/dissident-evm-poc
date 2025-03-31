// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import "../Base.t.sol";

contract UniV3ManagerTest is BaseTest {
    int24 constant TICK_LOWER = -100;
    int24 constant TICK_UPPER = 100;
    uint24 constant POOL_FEE = 3000;

    function setUp() public override {
        super.setUp();
    }
/*
    function testAddLiquidity() public {
        // Mint tokens to test accounts first
        deal(address(token0), ALICE, DEFAULT_AMOUNT);
        deal(address(token1), ALICE, DEFAULT_AMOUNT);
        
        vm.startPrank(ALICE);
        
        // Ensure token0 address is less than token1 address
        (address tokenA, address tokenB) = address(token0) < address(token1) 
            ? (address(token0), address(token1))
            : (address(token1), address(token0));
        
        uint256 amount0 = DEFAULT_AMOUNT;
        uint256 amount1 = DEFAULT_AMOUNT;
        
        // First deposit tokens to vault
        IERC20(tokenA).approve(address(dissident), amount0);
        IERC20(tokenB).approve(address(dissident), amount1);
        dissident.deposit(tokenA, amount0);
        dissident.deposit(tokenB, amount1);
        
        // Add liquidity
        (uint256 tokenId, uint128 liquidity) = uniV3Manager.addLiquidity(
            tokenA,
            tokenB,
            POOL_FEE,
            amount0,
            amount1,
            TICK_LOWER,
            TICK_UPPER
        );
        
        assertTrue(tokenId > 0);
        assertTrue(liquidity > 0);
        vm.stopPrank();
    }

    function testRemoveLiquidity() public {
        vm.startPrank(ALICE);
        uint256 amount0 = DEFAULT_AMOUNT;
        uint256 amount1 = DEFAULT_AMOUNT;
        
        // Setup: deposit and add liquidity
        token0.approve(address(dissident), amount0);
        token1.approve(address(dissident), amount1);
        dissident.deposit(address(token0), amount0);
        dissident.deposit(address(token1), amount1);
        
        (uint256 tokenId, ) = uniV3Manager.addLiquidity(
            address(token0),
            address(token1),
            POOL_FEE,
            amount0,
            amount1,
            TICK_LOWER,
            TICK_UPPER
        );
        
        // Remove liquidity
        uniV3Manager.removeLiquidity(tokenId, 1e18); // 100%
        
        // Check balances returned to vault
        assertGt(dissident.getTokenBalance(ALICE, address(token0)), 0);
        assertGt(dissident.getTokenBalance(ALICE, address(token1)), 0);
        vm.stopPrank();
    }

    function test_RevertWhen_AddLiquidityWithoutVaultBalance() public {
        vm.prank(ALICE);
        vm.expectRevert("Insufficient balance");
        uniV3Manager.addLiquidity(
            address(token0),
            address(token1),
            POOL_FEE,
            DEFAULT_AMOUNT,
            DEFAULT_AMOUNT,
            TICK_LOWER,
            TICK_UPPER
        );
    }

    function test_RevertWhen_RemoveUnauthorizedPosition() public {
        vm.startPrank(ALICE);
        uint256 amount0 = DEFAULT_AMOUNT;
        uint256 amount1 = DEFAULT_AMOUNT;
        
        token0.approve(address(dissident), amount0);
        token1.approve(address(dissident), amount1);
        dissident.deposit(address(token0), amount0);
        dissident.deposit(address(token1), amount1);
        
        (uint256 tokenId, ) = uniV3Manager.addLiquidity(
            address(token0),
            address(token1),
            POOL_FEE,
            amount0,
            amount1,
            TICK_LOWER,
            TICK_UPPER
        );
        vm.stopPrank();
        
        // Try to remove liquidity as BOB
        vm.prank(BOB);
        vm.expectRevert("Not position owner");
        uniV3Manager.removeLiquidity(tokenId, 1e18);
    }
    */
}
