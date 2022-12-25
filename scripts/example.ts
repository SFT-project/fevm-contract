import { BigNumber, ethers } from "ethers";
import * as dotenv from "dotenv";

dotenv.config();

const depositContractAddress = "0xC088e0a7ceBde86aa7DFE7765B609957f2A48Bd6"
const depositContractAbi = [
  `function takeTokens(address recipient) external`,
  `function mintSFT(address[] calldata userList, uint[] calldata amountList) external`
]
const PRIVATE_KEY = process.env.PRIVATE_KEY as string
const BSC_TESTNET_RPC = process.env.BSC_TESTNET_RPC
async function main() {
  const provider = new ethers.providers.JsonRpcProvider(BSC_TESTNET_RPC)
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider)
  // 获取Deposit合约实例并连接钱包
  const depositContract = new ethers.Contract(depositContractAddress, depositContractAbi).connect(wallet)
  // 调用Deposit合约中的方法
  // 取走合约中所有质押进来的FIL
  const recipient = "0x49554923b9361e158Fb267B436f843a4f537D53a"
  let tx = await depositContract.connect(wallet).takeTokens(recipient) //也可以在调用具体方法时再连接钱包：
  // 等待交易确认，receipt中可以拿到相关事件信息
  let recepit = await tx.wait()
  console.log("take tokens finished")
  const userList = ["0x49554923b9361e158Fb267B436f843a4f537D53a", "0x5B4e3C586B2f8AE1B10BC61F4A7997b2a16684c0", "0x523634018B6D364191DF325B2D54969B05e91F2C"]
  const amountList = [BigNumber.from("100000000000000000000"), BigNumber.from("200000000000000000000"), BigNumber.from("300000000000000000000")]
  tx = await depositContract.mintSFT(userList, amountList)
  recepit = await tx.wait()
  console.log("mint SFT finished")
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().then(() => {
  console.log("main: exit")
  process.exitCode = 0;
}).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
