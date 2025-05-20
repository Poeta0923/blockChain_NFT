const UsedBookMarketplace = artifacts.require("UsedBookMarketplace");

module.exports = function (deployer) {
  deployer.deploy(UsedBookMarketplace);
};