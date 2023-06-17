const NodusVault = artifacts.require("NodusVault");
const Nodus = artifacts.require("Nodus");
const usdcAddress = "0x8FB1E3fC51F3b789dED7557E680551d93Ea9d892";

module.exports = async function (deployer) {
  await deployer.deploy(NodusVault, usdcAddress);
  const nodusVault = await NodusVault.deployed();

  // Deploy Nodus with address of NodusVault
  await deployer.deploy(Nodus, usdcAddress, nodusVault.address);
};
