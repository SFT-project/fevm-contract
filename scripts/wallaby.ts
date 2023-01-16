import { ethers, getNamedAccounts, deployments } from "hardhat";

async function main() {
    const { deployer, minterAddress, takerAddress, distributorAddress } = await getNamedAccounts();
    const signer = await ethers.getSigner(deployer);

    const DepositProxyDeployments = await deployments.get("DepositProxy");
    const Deposit = await ethers.getContractAt("Deposit", DepositProxyDeployments.address, signer);
    let tx = await Deposit.setMinter(minterAddress, { maxPriorityFeePerGas: ethers.BigNumber.from("5000000000") });
    await tx.wait();
    console.log(`set minter: ${minterAddress}`);
    tx = await Deposit.setTaker(takerAddress, { maxPriorityFeePerGas: ethers.BigNumber.from("5000000000") });
    await tx.wait();
    console.log(`set taker: ${takerAddress}`);

    const RewardProxyDeployments = await deployments.get("RewardProxy");
    const Reward = await ethers.getContractAt("Reward", RewardProxyDeployments.address, signer);
    tx = await Reward.setDistributor(distributorAddress, { maxPriorityFeePerGas: ethers.BigNumber.from("5000000000") });
    await tx.wait();
    console.log(`set distributor: ${distributorAddress}`);
}

main().then(() => {
  console.log("main: exit")
  process.exitCode = 0;
}).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});