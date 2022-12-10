import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
 
const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, ethers, getNamedAccounts } = hre;
    const { deployer, filTokenAddress, approverAddress, authorityAddress, oracleAddress } = await getNamedAccounts();
    const signer = await ethers.getSigner(deployer);

    // deploy Deposit contract
    const DepositResult = await deployments.deploy("Deposit", {
        from: deployer,
        args: []
    });
    console.log(`Deposit contract address: ${DepositResult.address}`);
    // deploy ProxyAdmin contract
    const ProxyAdminResult = await deployments.deploy("ProxyAdmin", {
        from: deployer,
        args: [],
    });
    console.log(`ProxyAdmin contract address: ${ProxyAdminResult.address}`);
    // deploy Proxy contract
    const ProxyResult = await deployments.deploy("DepositProxy", {
        from: deployer,
        args: [DepositResult.address, ProxyAdminResult.address, "0x"],
        contract: "TransparentUpgradeableProxy",
    });
    console.log(`Proxy contract address: ${ProxyResult.address}`);
    const Deposit = await ethers.getContractAt("Deposit", ProxyResult.address, signer);
    const SFTTokenDeployment = await deployments.get("SFTToken");
    const demandDepositLimit = ethers.BigNumber.from('30000000000000000000000000');
    const mutex = true;
    const applyCount = 1;
    const initializeTx = await Deposit.initialize(filTokenAddress, SFTTokenDeployment.address, authorityAddress, approverAddress, oracleAddress, demandDepositLimit, mutex, applyCount);
    await initializeTx.wait();
    console.log('Deposit contract initilize successfully.');
    // add SFT token minter
    const SFTToken = await ethers.getContractAt("SFTToken", SFTTokenDeployment.address, signer);
    const addMinterTx = await SFTToken.addMinter(ProxyResult.address)
    await addMinterTx.wait();
    console.log(`add SFT token minter for Deposit contract successfully`)
}

export default func;
func.tags = ["Deposit"];