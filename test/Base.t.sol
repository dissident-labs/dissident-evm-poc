// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "../src/Dissident.sol";
import "./utils/TestUtils.sol";
import "../src/mocks/MockERC20.sol";
import "../src/mocks/MockMetaPool.sol";
import "../src/mocks/MockNonfungiblePositionManager.sol";
import "../src/mocks/MockWETH9.sol";

contract BaseTest is Test, TestUtils {
    Dissident public dissident;
    MockMetaPool public metaPool;
    MockERC20 public storyToken;
    MockERC20 public token0;
    MockERC20 public token1;
    MockERC20 public rewardToken;
    MockNonfungiblePositionManager public nftManager;
    MockWETH9 public weth;
    
    function setUp() public virtual {
        // Deploy mock tokens
        storyToken = new MockERC20("Story Token", "STORY");
        token0 = new MockERC20("Token0", "TK0");
        token1 = new MockERC20("Token1", "TK1");
        rewardToken = new MockERC20("Reward Token", "RWD");
        
        // Deploy mock MetaPool
        metaPool = new MockMetaPool(address(storyToken));
        
        // Deploy mock NFT manager and WETH
        nftManager = new MockNonfungiblePositionManager();
        weth = new MockWETH9();
        
        // Deploy main Dissident contract
        dissident = new Dissident(
            address(metaPool),
            address(storyToken),
            address(nftManager),
            address(weth)
        );

        
        
        // Fund test accounts
        vm.deal(ALICE, 1000 ether);
        vm.deal(BOB, 1000 ether);
        
        // Mint initial token balances
        token0.mint(ALICE, INITIAL_BALANCE);
        token1.mint(ALICE, INITIAL_BALANCE);
        storyToken.mint(ALICE, INITIAL_BALANCE);
        rewardToken.mint(address(metaPool), INITIAL_BALANCE);
    }
}
