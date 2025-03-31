// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

interface IUniV3Manager {
    function addLiquidity(
        address token0,
        address token1,
        uint24 fee,
        uint256 amount0Desired,
        uint256 amount1Desired,
        int24 tickLower,
        int24 tickUpper
    ) external payable returns (uint256 tokenId, uint128 liquidity);

    function removeLiquidity(
        uint256 tokenId,
        uint128 liquidityPercentage
    ) external;

    function adjustPositionRange(
        uint256 tokenId,
        int24 newTickLower,
        int24 newTickUpper
    ) external payable;

    function pause() external;
    function unpause() external;
}