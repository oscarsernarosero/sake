var CreditToken = artifacts.require("CreditToken"); // First
var LendingPool = artifacts.require("LendingPool"); // Second
require("dotenv").config({path: "../.env"});
// var BN = web3.utils.BN;

// Function to deploy
module.exports = async function(deployer) {
    let addresses = await web3.eth.getAccounts();

    await deployer.deploy(CreditToken);

    await deployer.deploy(LendingPool, 100); // Need to figure out how to deploy with a Big Number
}