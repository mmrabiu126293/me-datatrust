# ME DataTrust: Smart Contracts

Solidity contracts for ME DataTrust, a data verification platform built on ME Network.

The `DataTrustRegistry` contract stores dataset fingerprints (SHA-256 hashes) on-chain so anyone can later check whether a file has been modified since it was registered. Datasets themselves are never stored on-chain.

## Setup

npm install
npx hardhat compile
npx hardhat test

## Status

In development for MetaEarth Hackathon 2026: HARBOR.