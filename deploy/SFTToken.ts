import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
 
const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, ethers, getNamedAccounts } = hre;
    const { deployer } = await getNamedAccounts();
    const signer = await ethers.getSigner(deployer);

    const SFTTokenResult = await deployments.deploy("SFTToken", { from: deployer, args: [] });
    console.log(`SFTToken contract address: ${SFTTokenResult.address}`)
}

export default func;
func.tags = ["SFTToken"];