import { ethers, getNamedAccounts, deployments } from "hardhat";

async function main() {
    const { deployer } = await getNamedAccounts();
    const signer = await ethers.getSigner(deployer);

    const ProxyDeployments = await deployments.get("RewardProxy");
    const Reward = await ethers.getContractAt("Reward", ProxyDeployments.address, signer);
    const user = "0x49554923b9361e158Fb267B436f843a4f537D53a";
    const pid = 1;
    const result = await Reward.getUserInfo(user, pid)
    console.log(result)
}

main().then(() => {
  console.log("main: exit")
  process.exitCode = 0;
}).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});