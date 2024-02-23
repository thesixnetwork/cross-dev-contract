import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
const fs = require("fs");

const mnemonic = fs.readFileSync("./.secret").toString().trim();

const config: HardhatUserConfig = {
  defaultNetwork: "testnet_goerli",
  networks: {
    hardhat: {
    },
    testnet_goerli: {
      url: "https://ethereum-goerli.publicnode.com",
      accounts: [mnemonic]
    },
    testnet_sepolia: {
      url: "https://proud-still-snow.ethereum-sepolia.quiknode.pro/6caab2c6d1ecb19e3697697d569944fe67109338",
      accounts: [mnemonic]
    },
    testnet_blast: {
      url: "https://magical-silent-tab.blast-sepolia.quiknode.pro/9ad69164432ae5e9bc23fccc27b506e3169c873d",
      accounts: [mnemonic]
    }
  },
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  
  etherscan: {
    apiKey: {
      blast_sepolia: "blast_sepolia", // apiKey is not required, just set a placeholder
    },
    customChains: [
      {
        network: "blast_sepolia",
        chainId: 168587773,
        urls: {
          apiURL: "https://api.routescan.io/v2/network/testnet/evm/168587773/etherscan",
          browserURL: "https://testnet.blastscan.io"
        }
      }
    ]
  },
};

export default config;














// const config: HardhatUserConfig = {
//   solidity: "0.8.19",
//   etherscan: {
//     apiKey: {
//       blast_sepolia: "blast_sepolia", // apiKey is not required, just set a placeholder
//     },
//     customChains: [
//       {
//         network: "blast_sepolia",
//         chainId: 168587773,
//         urls: {
//           apiURL: "https://api.routescan.io/v2/network/testnet/evm/168587773/etherscan",
//           browserURL: "https://testnet.blastscan.io"
//         }
//       }
//     ]
//   },
//   networks: {
//     // for mainnet
//     "blast-mainnet": {
//       url: "coming end of February",
//       accounts: [process.env.PRIVATE_KEY as string],
//       gasPrice: 1000000000,
//     },
//     // for Sepolia testnet
//     "blast-sepolia": {
//       url: "https://magical-silent-tab.blast-sepolia.quiknode.pro/9ad69164432ae5e9bc23fccc27b506e3169c873d/",
//       // url: "https://sepolia.blast.io",
//       accounts: [process.env.PRIVATE_KEY as string],
//       gasPrice: 1000000000,
//     },
//     // for local dev environment
//     "blast-local": {
//       url: "http://localhost:8545",
//       accounts: [process.env.PRIVATE_KEY as string],
//       gasPrice: 1000000000,
//     },
//   },
//   defaultNetwork: "blast-local",

// };
