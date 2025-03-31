// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '../interfaces/IWETH9Local.sol';
import '../interfaces/IDissident.sol';

library UniV3Manager {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct UniV3State {
        INonfungiblePositionManager nonfungiblePositionManager;
        IWETH9Local WNative;
    }

    function addLiquidity(
        UniV3State storage state,
        address token0,
        address token1,
        uint24 fee,
        uint256 amount0Desired,
        uint256 amount1Desired,
        int24 tickLower,
        int24 tickUpper
    ) external returns (uint256 tokenId, uint128 liquidity) {
        // Ensure token addresses are in the correct order
        require(token0 < token1, "Invalid token order");

        // Approve tokens to position manager
        IERC20(token0).approve(address(state.nonfungiblePositionManager), amount0Desired);
        IERC20(token1).approve(address(state.nonfungiblePositionManager), amount1Desired);

        // Create mint params
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager
            .MintParams({
                token0: token0,
                token1: token1,
                fee: fee,
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            });

        // Mint position
        (tokenId, liquidity, , ) = state.nonfungiblePositionManager.mint(params);
        require(liquidity > 0, "No liquidity added");

        return (tokenId, liquidity);
    }

    function removeLiquidity(
        UniV3State storage state,
        uint256 tokenId,
        uint128 liquidityPercentage,
        address recipient
    ) external returns (uint256 amount0, uint256 amount1) {
        require(liquidityPercentage <= 1e18, "Invalid liquidity percentage");

        // Get position info
        (, , , , , , , uint128 positionLiquidity, , , , ) = 
            state.nonfungiblePositionManager.positions(tokenId);

        uint128 liquidityToRemove = uint128((uint256(positionLiquidity) * liquidityPercentage) / 1e18);
        require(liquidityToRemove > 0, "No liquidity to remove");

        // Remove liquidity
        INonfungiblePositionManager.DecreaseLiquidityParams memory params =
            INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: tokenId,
                liquidity: liquidityToRemove,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            });
            
        state.nonfungiblePositionManager.decreaseLiquidity(params);

        // Collect tokens
        INonfungiblePositionManager.CollectParams memory collectParams =
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: recipient,
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            });
            
        (amount0, amount1) = state.nonfungiblePositionManager.collect(collectParams);

        return (amount0, amount1);
    }

    function handleNativeToken(
        UniV3State storage state,
        bool isNative,
        uint256 amount
    ) external {
        if (isNative) {
            state.WNative.deposit{value: amount}();
        }
    }

    function unwrapNativeToken(
        UniV3State storage state,
        uint256 amount
    ) external {
        state.WNative.withdraw(amount);
    }
} 