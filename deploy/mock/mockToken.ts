import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
 
const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, ethers, getNamedAccounts } = hre;
    const { deployer } = await getNamedAccounts();
    const signer = await ethers.getSigner(deployer);

    const MockTokenResult = await deployments.deploy("MockToken",
        {
            from: deployer,
            args: [],
            maxPriorityFeePerGas: ethers.BigNumber.from("5000000000"),
            log: true
        });
    console.log(`MockToken contract address: ${MockTokenResult.address}`)
}


export default func;
func.tags = ["MockToken"];