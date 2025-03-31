// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./interfaces/IDissident.sol";
import "./interfaces/IMetaPool.sol";
import "./interfaces/IWETH9.sol";
import "./libraries/UniV3Manager.sol";

contract Dissident is IDissident, Pausable, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using UniV3Manager for UniV3Manager.UniV3State;

    // Storage variables moved from VaultManager
    mapping(address => mapping(address => uint256)) private tokenBalances;
    mapping(address => uint256) private nativeBalances;
    mapping(address => bool) public override authorizedManagers;
    
    // Mapping from user address to their positions
    mapping(address => Position[]) private _userPositions;
    
    // Original Dissident storage
    mapping(address => uint256) public _userStakes;
    
    // Protocol contracts
    //UniV3Manager public immutable _uniV3Manager;
    
    // External contracts
    IMetaPool public immutable metaPool;
    IERC20 public immutable storyToken;
    IERC20 public immutable rewardToken;

    UniV3Manager.UniV3State private uniV3State;

    constructor(
        address _metaPool,
        address _storyToken,
        address _nftManager,
        address _weth
    ) {
        require(_metaPool != address(0), "Invalid meta pool");
        require(_storyToken != address(0), "Invalid story token");
        require(_nftManager != address(0), "Invalid NFT manager");
        require(_weth != address(0), "Invalid WETH");

        // Store external contracts
        metaPool = IMetaPool(_metaPool);
        storyToken = IERC20(_storyToken);
        rewardToken = IERC20(_storyToken); // Using same token for rewards

        // Initialize UniV3State
        uniV3State.nonfungiblePositionManager = INonfungiblePositionManager(_nftManager);
        uniV3State.WNative = IWETH9Local(_weth);
    }
    

    function setManager(address manager, bool authorized) external override onlyOwner {
        authorizedManagers[manager] = authorized;
        emit ManagerSet(manager, authorized);
    }

    function deposit(address token, uint256 amount) external override whenNotPaused nonReentrant {
        require(amount > 0, "Invalid amount");
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        tokenBalances[msg.sender][token] += amount;
    }
    
    function withdraw(address token, uint256 amount) external override {
        require(amount > 0, "Invalid amount");
        require(tokenBalances[msg.sender][token] >= amount, "Insufficient balance");
        
        tokenBalances[msg.sender][token] -= amount;
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    function withdrawNative(uint256 amount) external override {
        require(amount > 0, "Invalid amount");
        require(nativeBalances[msg.sender] >= amount, "Insufficient balance");
        
        nativeBalances[msg.sender] -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "ETH transfer failed");
    }

    function getTokenBalance(address user, address token) external view override returns (uint256) {
        return tokenBalances[user][token];
    }

    function getNativeBalance(address user) external view override returns (uint256) {
        return nativeBalances[user];
    }

    function _deductTokenBalance(address user, address token, uint256 amount) private {
        require(authorizedManagers[msg.sender], "Not authorized");
        require(tokenBalances[user][token] >= amount, "Insufficient balance");
        tokenBalances[user][token] -= amount;
    }

    function _creditTokenBalance(address user, address token, uint256 amount) private {
        require(authorizedManagers[msg.sender], "Not authorized");
        tokenBalances[user][token] += amount;
    }

    function _deductNativeBalance(address user, uint256 amount) private {
        require(authorizedManagers[msg.sender], "Not authorized");
        require(nativeBalances[user] >= amount, "Insufficient balance");
        nativeBalances[user] -= amount;
    }

    function _creditNativeBalance(address user, uint256 amount) private {
        require(authorizedManagers[msg.sender], "Not authorized");
        nativeBalances[user] += amount;
    }

    function findPosition(address user, uint256 tokenId) external view override returns (Position memory position, uint256 index) {
        Position[] memory positions = _userPositions[user];
        for (uint256 i = 0; i < positions.length; i++) {
            if (positions[i].tokenId == tokenId) {
                return (positions[i], i);
            }
        }
        return (Position(0, 0, address(0), address(0), 0, 0, TokenType.ERC20, TokenType.ERC20), 0);
    }

    function isPositionOwner(address user, uint256 tokenId) external view override returns (bool) {
        Position[] memory positions = _userPositions[user];
        for (uint256 i = 0; i < positions.length; i++) {
            if (positions[i].tokenId == tokenId) {
                return true;
            }
        }
        return false;
    }

    function removePosition(address user, uint256 index) external override {
        require(authorizedManagers[msg.sender], "Not authorized");
        require(index < _userPositions[user].length, "Invalid index");
        _userPositions[user][index] = _userPositions[user][_userPositions[user].length - 1];
        _userPositions[user].pop();
    }

    function updatePositionLiquidity(address user, uint256 index, uint128 newLiquidity) external override {
        require(authorizedManagers[msg.sender], "Not authorized");
        require(index < _userPositions[user].length, "Invalid index");
        _userPositions[user][index].liquidity = newLiquidity;
    }

    function updatePositionRange(
        address user,
        uint256 index,
        int24 newTickLower,
        int24 newTickUpper,
        uint128 newLiquidity
    ) external override {
        require(authorizedManagers[msg.sender], "Not authorized");
        require(index < _userPositions[user].length, "Invalid index");
        Position storage position = _userPositions[user][index];
        uint128 oldLiquidity = position.liquidity;
        position.tickLower = newTickLower;
        position.tickUpper = newTickUpper;
        position.liquidity = newLiquidity;
        emit PositionRangeAdjusted(position.tokenId, newTickLower, newTickUpper, oldLiquidity, newLiquidity);
    }

    function userStakes(address user) external view override returns (uint256) {
        return _userStakes[user];
    }

    function userPositions(address user, uint256 index) external view override returns (Position memory) {
        require(index < _userPositions[user].length, "Invalid index");
        return _userPositions[user][index];
    }

    function pause() external override onlyOwner {
        _pause();
    }

    function unpause() external override onlyOwner {
        _unpause();
    }

    function stake(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "Invalid amount");
        require(nativeBalances[msg.sender] >= amount, "Insufficient balance");
        
        // Deduct from user's native balance
        nativeBalances[msg.sender] = nativeBalances[msg.sender].sub(amount);
        
        // Forward ETH to MetaPool
        metaPool.stake{value: amount}();
        _userStakes[msg.sender] = _userStakes[msg.sender].add(amount);
        emit Staked(msg.sender, amount);
    }
    
    function unstake(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "Invalid amount");
        require(_userStakes[msg.sender] >= amount, "Insufficient stake");
        // Call MetaPool's unstake
        metaPool.unstake(amount);
        _userStakes[msg.sender] = _userStakes[msg.sender].sub(amount);
        nativeBalances[msg.sender] = nativeBalances[msg.sender].add(amount);

        emit Unstaked(msg.sender, amount);
    }

    function getStakedBalance(address user) external view returns (uint256) {
        return metaPool.stakedBalances(user);
    }

    function autoCompound() external whenNotPaused nonReentrant {
        // Claim and restake rewards
        metaPool.claimRewards();
        uint256 rewardBalance = rewardToken.balanceOf(address(this));
        if (rewardBalance > 0) {
            metaPool.stake{value: rewardBalance}();
        }
    }

    function _createPosition(
        address user,
        LiquidityParams memory params,
        uint256 tokenId,
        uint128 liquidity
    ) private{
        //require(authorizedManagers[msg.sender], "Not authorized");
        require(tokenId > 0, "Invalid token ID");
        require(liquidity > 0, "Invalid liquidity");

        // Create new position
        Position memory position = Position({
            tokenId: tokenId,
            liquidity: liquidity,
            token0: params.isToken0Native ? address(0) : params.token0,
            token1: params.isToken1Native ? address(0) : params.token1,
            tickLower: params.tickLower,
            tickUpper: params.tickUpper,
            token0Type: params.isToken0Native ? TokenType.NATIVE : TokenType.ERC20,
            token1Type: params.isToken1Native ? TokenType.NATIVE : TokenType.ERC20
        });

        // Store position
        _userPositions[user].push(position);

        emit PositionCreated(
            user,
            tokenId,
            position.token0,
            position.token1,
            liquidity,
            params.tickLower,
            params.tickUpper
        );
    }

    function depositNative() external payable override whenNotPaused nonReentrant {
        require(msg.value > 0, "Invalid amount");
        nativeBalances[msg.sender] = nativeBalances[msg.sender].add(msg.value);
        emit NativeDeposited(msg.sender, msg.value);
    }

    /// @notice Adds liquidity to a Uniswap V3 pool
    /// @param token0 Address of token0 (must be < token1)
    /// @param token1 Address of token1
    /// @param fee Pool fee tier
    /// @param amount0Desired Amount of token0 to add
    /// @param amount1Desired Amount of token1 to add
    /// @param tickLower Lower tick of position
    /// @param tickUpper Upper tick of position
    function addLiquidity(
        address token0,
        address token1,
        uint24 fee,
        uint256 amount0Desired,
        uint256 amount1Desired,
        int24 tickLower,
        int24 tickUpper
    ) external whenNotPaused nonReentrant returns (uint256 tokenId, uint128 liquidity) {
        // Check balances
        require(tokenBalances[msg.sender][token0] >= amount0Desired, "Insufficient token0 balance");
        require(tokenBalances[msg.sender][token1] >= amount1Desired, "Insufficient token1 balance");

        // Deduct tokens from user's balance
        tokenBalances[msg.sender][token0] -= amount0Desired;
        tokenBalances[msg.sender][token1] -= amount1Desired;

        // Add liquidity using UniV3Manager library
        (tokenId, liquidity) = uniV3State.addLiquidity(
            token0,
            token1,
            fee,
            amount0Desired,
            amount1Desired,
            tickLower,
            tickUpper
        );

        // Create position params
        LiquidityParams memory params = LiquidityParams({
            token0: token0,
            token1: token1,
            fee: fee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            amount0: amount0Desired,
            amount1: amount1Desired,
            isToken0Native: false,
            isToken1Native: false
        });

        // Create position record
        _createPosition(
            msg.sender,
            params,
            tokenId,
            liquidity
        );

        emit LiquidityAdded(
            msg.sender,
            tokenId,
            token0,
            token1,
            amount0Desired,
            amount1Desired,
            liquidity
        );

        return (tokenId, liquidity);
    }

    receive() external payable {}
    fallback() external payable {}
}
