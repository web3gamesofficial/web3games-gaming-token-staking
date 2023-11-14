import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-ethers';
import '@nomicfoundation/hardhat-viem';
import '@openzeppelin/hardhat-upgrades';
import 'hardhat-gas-reporter';
import 'hardhat-contract-sizer';
import 'hardhat-abi-exporter';
import '@typechain/hardhat';
import 'solidity-coverage';

import dotenv from 'dotenv';
import { parseUnits } from 'ethers';

dotenv.config();

const { ETH_MNEMONIC, ETH_PRIVATE_KEY, ALCHEMY_API_KEY } = process.env;

const MNEMONIC = ETH_MNEMONIC || '';
const ACCOUNTS = MNEMONIC ? { mnemonic: MNEMONIC } : ETH_PRIVATE_KEY ? [ETH_PRIVATE_KEY] : [];

const config: HardhatUserConfig = {
  defaultNetwork: 'hardhat',
  solidity: {
    compilers: [
      {
        version: '0.8.21',
        settings: {
          // evmVersion: 'shanghai', // PUSH0
          evmVersion: 'paris',
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    mainnet: {
      chainId: 1,
      url: `https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: ACCOUNTS,
    },
    goerli: {
      chainId: 5,
      url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: ACCOUNTS,
    },
    mumbai: {
      chainId: 80001,
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: ACCOUNTS,
    },
    polygon: {
      chainId: 137,
      url: `https://polygon-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: ACCOUNTS,
      gasPrice: 95853731849,
    },
    hardhat: {
      chainId: 1337,
    },
  },
  paths: {
    artifacts: './artifacts',
    cache: './cache',
    sources: './contracts',
    tests: './test',
  },
  gasReporter: {
    enabled: false,
  },
  etherscan: {
    apiKey: '',
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: false,
    disambiguatePaths: false,
  },
  abiExporter: {
    runOnCompile: true,
    clear: true,
    flat: true,
    pretty: true,
  },
  typechain: {
    outDir: 'types',
    target: 'ethers-v6',
  },
  mocha: {
    timeout: 0,
  },
};

export default config;
