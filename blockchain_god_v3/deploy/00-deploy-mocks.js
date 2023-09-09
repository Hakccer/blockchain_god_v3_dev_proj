const { network } = require("hardhat")
const hre = require("hardhat")
const { developmentChains, networkConfig } = require("../helper-hardhat-config")

const BASE_FEE = "250000000000000000" // 0.25 is this the premium in LINK?
const GAS_PRICE_LINK = 1e9 // link per gas, is this the gas lane? // 0.000000001 LINK per gas

module.exports = async()=>{
    const { deploy, log } = hre.deployments;
    const { deployer } = await hre.getNamedAccounts();
    // deploying the mocks here

    if (developmentChains.includes(network.name)){
        console.log("development enviroment detected...");
        console.log("deploying mocks...");
        const vrfMock = await deploy("VRFCoordinatorV2Mock",{
            from:deployer,
            log:true,
            args:[BASE_FEE, GAS_PRICE_LINK]
        })
        console.log("Deployed ------------------>");
    }
    
}

module.exports.tags = ["all", "mocks"]