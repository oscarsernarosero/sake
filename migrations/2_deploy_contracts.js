var creditToken = artifacts.require("CreditToken.sol");

module.exports = async function(deployer) {
  await deployer.deploy(creditToken);
}
