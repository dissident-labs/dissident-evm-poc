# Dissident - Story Protocol Yield Optimizer (PoC)

## Overview
Dissident is a proof of concept (PoC) for a yield optimization protocol built on top of Story Protocol. This project demonstrates how to efficiently manage yield-generating strategies through staking in MetaPool and providing/removing liquidity in PiperX.

## Features
- Native token staking in MetaPool
- Automated liquidity management in PiperX
- Vault system for asset management
- Unified interface for multiple yield strategies

## Key Components
- **VaultManager**: Handles asset deposits and withdrawals
- **StoryStakingManager**: Manages staking operations in MetaPool
- **UniV3Manager**: Handles liquidity provision in PiperX
- **Dissident**: Main contract that orchestrates all operations

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
