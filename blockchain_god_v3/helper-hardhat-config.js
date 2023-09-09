const { ethers } = require("hardhat")

const networkConfig = {
    11155111:{
        name: "sepolia",
        vrf_address: "0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625",
        keyHash: "0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c",
        maxEntranceCount: 5,
        entranceFee: ethers.parseEther("0.1"),
        subId: "0",
        numWords:"1",
        nishaqInterval: "30",
        callBackGasLimit: "500000"
    },
    31337:{
        name:"hardhat",
        keyHash: "0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c",
        maxEntranceCount: 5,
        entranceFee: ethers.parseEther("0.1"),
        numWords:"1",
        nishaqInterval: "15",
        callBackGasLimit: "500000"
    }
}

const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    developmentChains
}