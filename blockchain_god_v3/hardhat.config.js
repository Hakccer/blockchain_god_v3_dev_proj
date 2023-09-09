require("@nomiclabs/hardhat-waffle")
require("@nomiclabs/hardhat-etherscan")
require("dotenv").config()
require("hardhat-deploy")

/** @type import('hardhat/config').HardhatUserConfig */

const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const SEPOLIA_CHAINID = process.env.SEPOLIA_CHAINID;
const SEPOLIA_PRIVATE_KEY = process.env.SEPOLIA_PRIVATE_KEY;
const SEPOLIA_SECOND_PRIVATE_KEY = process.env.SEPOLIA_SECOND_PRIVATE_KEY;

module.exports = {
  solidity: "0.8.20",
  defaultNetwork:"hardhat",
  networks:{
    sepolia:{
      url:SEPOLIA_RPC_URL,
      accounts:[
        SEPOLIA_PRIVATE_KEY,
        SEPOLIA_SECOND_PRIVATE_KEY
      ],
      chainId:parseInt(SEPOLIA_CHAINID)
    }
  },
  etherscan:{
    apiKey:ETHERSCAN_API_KEY
  },
  namedAccounts:{
    deployer:{
      default:0,
    },
    player_one:{
      default:1
    },
    player_two:{
      default:2
    }
  },
  mocha: {
    timeout: 500000, // 500 seconds max for running tests
  }
};
