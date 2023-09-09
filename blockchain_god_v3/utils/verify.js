const hre = require("hardhat")


const verifyContract = async(contract_address, contruct_args)=>{
    // verifying the contract now here
    console.log(`Verifying Contract (addr => ${contract_address})`);
    try{
        await hre.run("verify:verify",{
            address:contract_address,
            args:contruct_args
        })
    }
    catch (e){
        if(e.message.toLowerCase().includes("already")){
            console.log("Contact already verified...");
        }
        else{
            console.log(`Exception => ${e.message}`);
        }
    }
    console.log("------------------------------------>");
};


module.exports ={
    verifyContract
}