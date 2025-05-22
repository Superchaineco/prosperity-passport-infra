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



Updating badges metadata
1. In utils run npm run pin-file (Need to param in .env the pinata api key)
2. Copy de hash to generateMetadata.js
3. npm run generate-metadata
4. Then go to smart-contracts tun forge compile
5. Copy the badges-with-uris.json to smart-contracts folder and/or change the badges.json depending the use
6. Use the UpdatesBadges (for all badges) or DeployNewBadges (for new badges or single badge updating)
7. e.g for BADGES_ADDRESS=0xd47C56513E640E394024FaCBBe5032cf604Bb699 forge script script/UpdateBadges.s.sol --rpc-url celo --account <ACCOUNT> --broadcast