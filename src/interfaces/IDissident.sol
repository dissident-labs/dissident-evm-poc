// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

interface IDissident {
    // Enums
    enum TokenType {
        ERC20,
        NATIVE
    }
    
    // Structs
    struct Position {
        uint256 tokenId;
        uint128 liquidity;
        address token0;
        address token1;
        int24 tickLower;
        int24 tickUpper;
        TokenType token0Type;
        TokenType token1Type;
    }

    struct LiquidityParams {
        address token0;
        address token1;
        uint24 fee;
        uint256 amount0;
        uint256 amount1;
        int24 tickLower;
        int24 tickUpper;
        bool isToken0Native;
        bool isToken1Native;
    }

    // Events
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event StrategyExecuted(address indexed user, string strategy, uint256 amount);
    event ManagerSet(address indexed manager, bool authorized);
    event PositionRangeAdjusted(
        uint256 indexed tokenId,
        int24 newTickLower,
        int24 newTickUpper,
        uint128 oldLiquidity,
        uint128 newLiquidity
    );
    event PositionCreated(
        address indexed user,
        uint256 tokenId,
        address token0,
        address token1,
        uint128 liquidity,
        int24 tickLower,
        int24 tickUpper
    );
    event NativeDeposited(address indexed user, uint256 amount);
    event LiquidityAdded(
        address indexed user,
        uint256 tokenId,
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1,
        uint128 liquidity
    );

    // View functions
    function userPositions(address user, uint256 index) external view returns (Position memory);
    function authorizedManagers(address manager) external view returns (bool);
    function userStakes(address user) external view returns (uint256);

    // Manager functions
    function setManager(address manager, bool authorized) external;

    // Balance functions
    function deposit(address token, uint256 amount) external;
    function withdraw(address token, uint256 amount) external;
    function getTokenBalance(address user, address token) external view returns (uint256);
    function getNativeBalance(address user) external view returns (uint256);
    function depositNative() external payable;
    function withdrawNative(uint256 amount) external;

    function findPosition(address user, uint256 tokenId) external view returns (Position memory position, uint256 index);
    function isPositionOwner(address user, uint256 tokenId) external view returns (bool);
    function removePosition(address user, uint256 index) external;
    function updatePositionLiquidity(address user, uint256 index, uint128 newLiquidity) external;
    function updatePositionRange(
        address user,
        uint256 index,
        int24 newTickLower,
        int24 newTickUpper,
        uint128 newLiquidity
    ) external;

    // System functions
    function pause() external;
    function unpause() external;

    /*function createPosition(
        address user,
        LiquidityParams memory params,
        uint256 tokenId,
        uint128 liquidity
    ) external;*/
}
