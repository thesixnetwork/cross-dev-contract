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
    testnet_blast: {
      url: "https://magical-silent-tab.blast-sepolia.quiknode.pro/9ad69164432ae5e9bc23fccc27b506e3169c873d",
      accounts: [mnemonic]
    }
  },
  solidity: "0.8.19",
};

export default config;
