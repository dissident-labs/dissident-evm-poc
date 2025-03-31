// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

interface IMintableToken {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
} 