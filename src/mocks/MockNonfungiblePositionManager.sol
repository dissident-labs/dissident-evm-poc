// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract MockNonfungiblePositionManager is INonfungiblePositionManager, ERC721 {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address private immutable _factory;
    address private immutable _WETH9;
    bytes32 private immutable _DOMAIN_SEPARATOR;
    bytes32 private constant _PERMIT_TYPEHASH = keccak256("Permit(address spender,uint256 tokenId,uint256 deadline)");

    uint256 private _nextTokenId = 1;
    
    struct PositionInfo {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint256 amount0;
        uint256 amount1;
    }

    mapping(uint256 => PositionInfo) private _positions;

    constructor() ERC721("Uniswap V3 Positions NFT-V1", "UNI-V3-POS") {
        _factory = address(this);
        _WETH9 = address(this);

        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        _DOMAIN_SEPARATOR = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name())),
            keccak256(bytes("1")),
            chainId,
            address(this)
        ));
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _DOMAIN_SEPARATOR;
    }

    function PERMIT_TYPEHASH() external pure override returns (bytes32) {
        return _PERMIT_TYPEHASH;
    }

    function WETH9() external view override returns (address) {
        return _WETH9;
    }

    function factory() external view override returns (address) {
        return _factory;
    }

    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable override {
        require(deadline >= block.timestamp, "Permit expired");
        // Mock implementation - no actual signature verification
        _approve(spender, tokenId);
    }

    function refundETH() external payable override {
        // Mock implementation
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "ETH transfer failed");
    }

    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable override {
        // Mock implementation
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance >= amountMinimum, "Insufficient token balance");
        IERC20(token).safeTransfer(recipient, balance);
    }

    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable override {
        // Mock implementation
        require(address(this).balance >= amountMinimum, "Insufficient WETH9 balance");
        (bool success, ) = recipient.call{value: address(this).balance}("");
        require(success, "ETH transfer failed");
    }

    function positions(uint256 tokenId)
        external
        view
        override
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        )
    {
        PositionInfo storage pos = _positions[tokenId];
        return (
            0,  // nonce
            address(0),  // operator
            pos.token0,
            pos.token1,
            pos.fee,
            pos.tickLower,
            pos.tickUpper,
            pos.liquidity,
            0,  // feeGrowthInside0LastX128
            0,  // feeGrowthInside1LastX128
            0,  // tokensOwed0
            0   // tokensOwed1
        );
    }

    function mint(MintParams calldata params)
        external
        payable
        override
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        tokenId = _nextTokenId;
        _nextTokenId = _nextTokenId.add(1);
        liquidity = uint128(params.amount0Desired); // Simplified liquidity calculation
        amount0 = params.amount0Desired;
        amount1 = params.amount1Desired;

        // Transfer tokens from sender
        if (amount0 > 0) {
            IERC20(params.token0).safeTransferFrom(msg.sender, address(this), amount0);
        }
        if (amount1 > 0) {
            IERC20(params.token1).safeTransferFrom(msg.sender, address(this), amount1);
        }

        // Store position
        _positions[tokenId] = PositionInfo({
            token0: params.token0,
            token1: params.token1,
            fee: params.fee,
            tickLower: params.tickLower,
            tickUpper: params.tickUpper,
            liquidity: liquidity,
            amount0: amount0,
            amount1: amount1
        });

        _mint(params.recipient, tokenId);
    }

    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        override
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        PositionInfo storage position = _positions[params.tokenId];
        require(position.token0 != address(0), "Invalid position");

        liquidity = uint128(params.amount0Desired);
        amount0 = params.amount0Desired;
        amount1 = params.amount1Desired;

        // Transfer tokens
        if (amount0 > 0) {
            IERC20(position.token0).safeTransferFrom(msg.sender, address(this), amount0);
        }
        if (amount1 > 0) {
            IERC20(position.token1).safeTransferFrom(msg.sender, address(this), amount1);
        }

        position.liquidity = uint128(uint256(position.liquidity).add(liquidity));
        position.amount0 = position.amount0.add(amount0);
        position.amount1 = position.amount1.add(amount1);
    }

    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        override
        returns (uint256 amount0, uint256 amount1)
    {
        PositionInfo storage position = _positions[params.tokenId];
        require(position.token0 != address(0), "Invalid position");
        require(position.liquidity >= params.liquidity, "Insufficient liquidity");

        // Calculate amounts proportionally
        amount0 = uint256(params.liquidity).mul(position.amount0).div(uint256(position.liquidity));
        amount1 = uint256(params.liquidity).mul(position.amount1).div(uint256(position.liquidity));

        position.liquidity = uint128(uint256(position.liquidity).sub(params.liquidity));
        position.amount0 = position.amount0.sub(amount0);
        position.amount1 = position.amount1.sub(amount1);
    }

    function collect(CollectParams calldata params)
        external
        payable
        override
        returns (uint256 amount0, uint256 amount1)
    {
        PositionInfo storage position = _positions[params.tokenId];
        require(position.token0 != address(0), "Invalid position");

        amount0 = position.amount0;
        amount1 = position.amount1;

        if (amount0 > 0) {
            IERC20(position.token0).safeTransfer(params.recipient, amount0);
        }
        if (amount1 > 0) {
            IERC20(position.token1).safeTransfer(params.recipient, amount1);
        }

        position.amount0 = 0;
        position.amount1 = 0;
    }

    function burn(uint256) external payable override {}

    function createAndInitializePoolIfNecessary(
        address,
        address,
        uint24,
        uint160
    ) external payable override returns (address) {
        return address(0);
    }
}
