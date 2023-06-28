# Nodus Smart Contracts

This repository contains the Nodus Smart Contracts built using the Solidity programming language. Nodus provides a mechanism for users to create, update, and purchase content and memberships, with payments managed through the USDC stablecoin.

## Smart Contracts

The two main contracts are:

1. **NodusVault**: A contract for securely storing and managing USDC tokens. Only the owner can withdraw funds from the vault.

2. **Nodus**: The main contract that handles content and membership management. It supports registering users, creating/updating/deleting content or memberships, purchasing content/memberships, and donating to content.

## Setup

1. Clone this repository to your local machine.

   ```
   git clone https://github.com/your-repo-url
   ```

2. Install dependencies.

   ```
   npm install
   ```

3. Create a `.env` file in the root of your project and add the following lines:

   ```
   MNEMONIC='your twelve word seed phrase'
   PROJECT_ID='your infura project id'
   ```

## Compilation and Deployment

1. Compile the smart contracts.

   ```
   truffle compile
   ```

2. To deploy the smart contracts on Arbitrum Goerli network, run:

   ```
   truffle migrate --network arbitrum
   ```

## Smart Contract Details

- **NodusVault**: Stores USDC tokens securely. Only the contract's owner can withdraw funds. Constructor takes the USDC contract's address as an argument.

- **Nodus**: The main contract managing the platform. It has functionalities for user registration, content and membership management, content purchase, membership purchase, and content donation. It emits events for content purchase, membership purchase, and donation. The contract includes a processing fee for each transaction.

Please replace `'your twelve word seed phrase'` and `'your infura project id'` in the `.env` file with your own mnemonic and Infura project ID.

## Important Note

Please make sure to never commit `.env` to Github. Add it to `.gitignore`. Your mnemonic and Infura project ID are sensitive pieces of information that should be kept secret.
