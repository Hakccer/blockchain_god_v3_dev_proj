const { network } = require("hardhat")
const { developmentChains, networkConfig } = require("../helper-hardhat-config");
const { verifyContract } = require("../utils/verify");

module.exports = async(hre)=>{
    const { deploy, log } = hre.deployments;
    const { deployer } = await hre.getNamedAccounts();
    // deploying the contract below now

    let vrf_addr, vrfMock, subscriptionId
    if (developmentChains.includes(network.name)){
        // Development enviroment process
        const vrfConrtact = await hre.ethers.getContract("VRFCoordinatorV2Mock")
        vrfMock = vrfConrtact
        vrf_addr = await vrfConrtact.getAddress();
        const my_transac_resp = await vrfConrtact.createSubscription()
        const transac_receipt = await my_transac_resp.wait(1);

        const vrfMockInterface = vrfConrtact.interface;

        const parsedLogs = transac_receipt.logs.map(log => vrfMockInterface.parseLog(log))
        console.log(parsedLogs);

        // now finally getting the subscriptionID;
        subscriptionId = (parsedLogs.find(a_log => a_log.name === "SubscriptionCreated")).args.subId;
    }
    else{
        vrf_addr = networkConfig[network.config.chainId]['vrf_address']
        subscriptionId = networkConfig[network.config.chainId]['subId']
    }

    const keyHash = networkConfig[network.config.chainId]['keyHash']
    const entranceFee = networkConfig[network.config.chainId]['entranceFee']
    const maxEntranceCount = networkConfig[network.config.chainId]['maxEntranceCount']
    const callBackGasLimit = networkConfig[network.config.chainId]['callBackGasLimit']
    const numWords = networkConfig[network.config.chainId]['numWords']
    const nishaqInterval = networkConfig[network.config.chainId]['nishaqInterval']

    let args = [
        entranceFee,
        maxEntranceCount,
        vrf_addr,
        keyHash,
        subscriptionId,
        callBackGasLimit,
        numWords,
        nishaqInterval
    ]
    const my_contract = await deploy("Nishaq",{
        from:deployer,
        log:true,
        args: args
    })

    await vrfMock.addConsumer(
        subscriptionId,
        my_contract
    )

    // verifying the contract now heres
    if(!developmentChains.includes(network.name)){
        console.log("verifying the contact here:");
        verifyContract(my_contract.address, args);
    }
}

module.exports.tags = ["all"]