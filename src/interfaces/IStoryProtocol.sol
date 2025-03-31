// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStoryProtocol is IERC20 {
    // No need to redeclare IERC20 functions since they're already inherited
    // Add any additional Story Protocol specific functions here if needed
}
