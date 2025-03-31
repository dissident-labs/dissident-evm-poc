// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

contract MockUniswapV3Pool is IUniswapV3Pool {
    address public immutable override token0;
    address public immutable override token1;
    uint24 public immutable override fee;

    int24 public override tickSpacing;
    uint128 public override liquidity;
    uint160 public sqrtPriceX96;
    int24 public tick;

    constructor(
        address _token0,
        address _token1,
        uint24 _fee,
        uint160 _sqrtPriceX96,
        int24 _tick
    ) {
        require(_token0 != address(0), "Invalid token0");
        require(_token1 != address(0), "Invalid token1");
        token0 = _token0;
        token1 = _token1;
        fee = _fee;
        sqrtPriceX96 = _sqrtPriceX96;
        tick = _tick;
        tickSpacing = 60;
    }

    function slot0()
        external
        view
        override
        returns (
            uint160 sqrtPriceX96_,
            int24 tick_,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        )
    {
        return (sqrtPriceX96, tick, 0, 0, 0, 0, true);
    }

    function initialize(uint160 sqrtPriceX96_) external override {
        sqrtPriceX96 = sqrtPriceX96_;
    }

    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external override returns (uint128 amount0, uint128 amount1) {
        // Mock implementation
        return (amount0Requested, amount1Requested);
    }

    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external override returns (uint128 amount0, uint128 amount1) {
        // Mock implementation
        return (amount0Requested, amount1Requested);
    }

    function feeGrowthGlobal0X128() external pure override returns (uint256) {
        return 0;
    }

    function feeGrowthGlobal1X128() external pure override returns (uint256) {
        return 0;
    }

    function maxLiquidityPerTick() external pure override returns (uint128) {
        return type(uint128).max;
    }

    function positions(bytes32)
        external
        pure
        override
        returns (
            uint128 liquidityAmount,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        )
    {
        return (0, 0, 0, 0, 0);
    }

    function protocolFees() external pure override returns (uint128, uint128) {
        return (0, 0);
    }

    function setFeeProtocol(uint8, uint8) external override {}

    function tickBitmap(int16) external pure override returns (uint256) {
        return 0;
    }

    function ticks(int24)
        external
        pure
        override
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        )
    {
        return (0, 0, 0, 0, 0, 0, 0, false);
    }

    function factory() external view override returns (address) { return address(0); }
    function mint(address, int24, int24, uint128, bytes calldata) external pure override returns (uint256, uint256) { return (0, 0); }
    function burn(int24, int24, uint128) external pure override returns (uint256, uint256) { return (0, 0); }
    function swap(address, bool, int256, uint160, bytes calldata) external pure override returns (int256, int256) { return (0, 0); }
    function flash(address, uint256, uint256, bytes calldata) external pure override {}
    function increaseObservationCardinalityNext(uint16) external pure override {}
    function observe(uint32[] calldata) external pure override returns (int56[] memory, uint160[] memory) {
        int56[] memory tickCumulatives = new int56[](0);
        uint160[] memory secondsPerLiquidityCumulativeX128s = new uint160[](0);
        return (tickCumulatives, secondsPerLiquidityCumulativeX128s);
    }
    function snapshotCumulativesInside(int24, int24) external pure override returns (int56, uint160, uint32) { return (0, 0, 0); }
    function observations(uint256) external pure override returns (uint32, int56, uint160, bool) { return (0, 0, 0, false); }
}
