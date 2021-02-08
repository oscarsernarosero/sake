//var CreditToken = artifacts.require("CreditToken.sol"); // First
var LendingPool = artifacts.require("LendingPool.sol"); // Second
require("dotenv").config({path: "../.env"});
// var BN = web3.utils.BN;

// Function to deploy
module.exports = async function(deployer) {
    let addresses = await web3.eth.getAccounts();

    //await deployer.deploy(CreditToken);

    await deployer.deploy(LendingPool, 1000000000000000);
}