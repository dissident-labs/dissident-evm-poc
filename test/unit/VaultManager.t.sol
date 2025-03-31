// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import "../Base.t.sol";
import "../../src/mocks/MockERC20.sol";

contract DissidentBalanceTest is BaseTest {
    MockERC20 public token;

    function setUp() public override {
        super.setUp();
        token = new MockERC20("Test Token", "TEST");
    }

    function testDeposit() public {
        uint256 amount = 100 ether;
        token.mint(ALICE, amount);
        
        vm.startPrank(ALICE);
        token.approve(address(dissident), amount);
        
        // Test deposit through Dissident
        dissident.deposit(address(token), amount);

        // Check balances
        assertEq(token.balanceOf(address(dissident)), amount);
        vm.stopPrank();
    }

    function testWithdraw() public {
        vm.startPrank(ALICE);
        uint256 amount = DEFAULT_AMOUNT;
        token.mint(ALICE, amount);
        
        token.approve(address(dissident), amount);
        dissident.deposit(address(token), amount);
        
        uint256 balanceBefore = token.balanceOf(ALICE);
        dissident.withdraw(address(token), amount);
        uint256 balanceAfter = token.balanceOf(ALICE);
        
        assertEq(balanceAfter - balanceBefore, amount);
        assertEq(dissident.getTokenBalance(ALICE, address(token)), 0);
        vm.stopPrank();
    }

    function test_RevertWhen_WithdrawTooMuch() public {
        vm.startPrank(ALICE);
        uint256 amount = DEFAULT_AMOUNT;
        
        token.mint(ALICE, amount);
        token.approve(address(dissident), amount);
        dissident.deposit(address(token), amount);
        vm.expectRevert("Insufficient balance");
        dissident.withdraw(address(token), amount + 1);
        vm.stopPrank();
    }

    function testManagerAuthorization() public {
        address newManager = address(0x123);
        
        // Only owner can set manager
        vm.prank(ALICE);
        vm.expectRevert("Ownable: caller is not the owner");
        dissident.setManager(newManager, true);
        
        // Owner can set manager
        dissident.setManager(newManager, true);
        assertTrue(dissident.authorizedManagers(newManager));
        
        // Owner can revoke manager
        dissident.setManager(newManager, false);
        assertFalse(dissident.authorizedManagers(newManager));
    }
}
