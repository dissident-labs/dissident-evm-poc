# Dissident - Story Protocol Yield Optimizer (PoC)

## Overview
Dissident is a proof of concept (PoC) for a yield optimization protocol built on top of Story Protocol. This project demonstrates how to efficiently manage yield-generating strategies through staking in MetaPool and providing/removing liquidity in Uniswap V3.

## ⚠️ Work in Progress
This project is currently under active development and is not ready for production use. Features and interfaces may change significantly as development continues.

## Features
- Native ETH staking in MetaPool with story token rewards
- Automated liquidity management in Uniswap V3
- Vault system for asset management
- Support for both ERC20 and native token operations
- Position tracking for Uniswap V3 liquidity positions
- Auto-compounding functionality for staking rewards

## Key Components
- **Dissident**: Main contract that orchestrates all operations and manages state
- **UniV3Manager**: Library for Uniswap V3 liquidity operations
- **MetaPool Integration**: For staking ETH and earning rewards
- **Position Management**: Tracking and managing Uniswap V3 positions

## Technical Stack
- Solidity 0.7.6
- Foundry for testing and deployment
- OpenZeppelin contracts
- Uniswap V3 periphery and core contracts

## Architecture

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## Development
```bash
# Install dependencies
forge install

# Run tests
forge test

# Deploy contracts
forge script scripts/Deploy.s.sol
```

## Testing
The project includes comprehensive test suites:
- Unit tests for individual components
- Integration tests for full workflow scenarios
- Mock contracts for external dependencies

## Security Considerations
- Pausable functionality for emergency stops
- ReentrancyGuard for all state-modifying functions
- Access control for manager functions
- Safe math operations for arithmetic
- Proper balance and allowance checks


## Contributing
This is a proof of concept project. Feel free to submit issues and pull requests.

## Current Status
- [x] Basic contract structure
- [x] Staking in MetaPool in Story
- [ ] Uniswap V3 integration
- [ ] Position management
- [ ] Advanced yield strategies
- [ ] Audit readiness
- [ ] Documentation completion

## License
MIT

## Disclaimer
This is an experimental proof of concept. Use at your own risk. Not audited and not ready for production use.

