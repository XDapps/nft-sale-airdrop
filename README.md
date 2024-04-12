# ERC-721 Sale Demo with ERC-20 Airdrop

This project demonstrates how to use Hardhat and Solidity to create an ERC-721 token contract and sale manager. Then allow NFT owners to claim an ERC-20 airdrop for a new reward token.

## Installation

1. Please see .example.env file and recreate a .env in the same format.
2. Navigate to your project directory and run:

```shell
yarn
```

```shell
npx hardhat test
```

## Deployment

1. Update proceeds disbursement address in scripts/deploy.ts.
2. Update collection name and symbol in scripts/deploy.ts.

*Example of how to deploy on Polygon*

*See hardhat.config.ts to add networks*

```shell
npx hardhat run scripts/deploy --network polygon
```
