import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, ethers, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);

  // deploy new BatchDeposit contract
  const Deposit = await deployments.deploy("Reward", {
    from: deployer,
    args: [],
  });
  console.log(`Deposit contract address: ${Deposit.address}`);

  // upgrade
  const ProxyAdminDeployments = await deployments.get("ProxyAdmin");
  const ProxyDeployments = await deployments.get("RewardProxy");
  const ProxyAdmin = await ethers.getContractAt(
    "ProxyAdmin",
    ProxyAdminDeployments.address,
    signer
  );
  const upgradeTx = await ProxyAdmin.upgrade(
    ProxyDeployments.address,
    Deposit.address
  );
  await upgradeTx.wait();
  console.log(
    `upgrade success, Proxy address:${ProxyDeployments.address}, new implementation address: ${Deposit.address}`
  );
};

export default func;
func.tags = ["UpgradeReward"];
