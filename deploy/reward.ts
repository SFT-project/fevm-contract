import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
 
const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, ethers, getNamedAccounts } = hre;
    const { deployer, filTokenAddress, distributorAddress } = await getNamedAccounts();
    const signer = await ethers.getSigner(deployer);

    // deploy Reward contract
    const RewardResult = await deployments.deploy("Reward", {
        from: deployer,
        args: []
    });
    console.log(`Reward contract address: ${RewardResult.address}`);
    // get ProxyAdmin contract
    const ProxyDeployment = await deployments.get("ProxyAdmin");
    // deploy Proxy contract
    const ProxyResult = await deployments.deploy("RewardProxy", {
        from: deployer,
        args: [RewardResult.address, ProxyDeployment.address, "0x"],
        contract: "TransparentUpgradeableProxy",
    });
    console.log(`Proxy contract address: ${ProxyResult.address}`);
    const Reward = await ethers.getContractAt("Reward", ProxyResult.address, signer);
    const SFTTokenDeployment = await deployments.get("SFTToken");
    const initializeTx = await Reward.initialize(filTokenAddress, SFTTokenDeployment.address, distributorAddress);
    await initializeTx.wait();
    console.log('Reward contract initilize successfully.');
}

export default func;
func.tags = ["Reward"];