// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../src/mocks/MockERC20.sol";
import "../../src/mocks/MockMetaPool.sol";
import "../../src/mocks/MockUniswapV3Pool.sol";
import "../../src/mocks/MockNonfungiblePositionManager.sol";

contract TestUtils is Test {
    address constant OWNER = address(0x1);
    address constant ALICE = address(0x1);
    address constant BOB = address(0x2);
    address constant CAROL = address(0x3);
    
    uint256 constant INITIAL_BALANCE = 1000000 ether;
    uint256 constant DEFAULT_AMOUNT = 1000 ether;
    
    function createToken(string memory name, string memory symbol) internal returns (MockERC20) {
        MockERC20 token = new MockERC20(name, symbol);
        return token;
    }

    function createAndMintToken(
        string memory name,
        string memory symbol,
        address to,
        uint256 amount
    ) internal returns (MockERC20) {
        MockERC20 token = createToken(name, symbol);
        token.mint(to, amount);
        return token;
    }

    function createMetaPool(address _storyToken) internal returns (MockMetaPool) {
        return new MockMetaPool(_storyToken);
    }

    function createUniV3Pool(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96,
        int24 tick
    ) internal returns (MockUniswapV3Pool) {
        // Ensure token0 < token1
        (address t0, address t1) = sortTokens(token0, token1);
        return new MockUniswapV3Pool(t0, t1, fee, sqrtPriceX96, tick);
    }

    function createNFTManager() internal returns (MockNonfungiblePositionManager) {
        return new MockNonfungiblePositionManager();
    }

    function assertEqWithDiff(uint256 a, uint256 b, uint256 maxDiff) internal pure {
        uint256 diff = a > b ? a - b : b - a;
        assertLe(diff, maxDiff, "Values differ by more than allowed");
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "Same token");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "Zero address");
    }
}
