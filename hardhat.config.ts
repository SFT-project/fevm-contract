import { HardhatUserConfig } from "hardhat/config";
import "hardhat-deploy";
import "@nomiclabs/hardhat-ethers";
import "hardhat-contract-sizer";
import "@nomicfoundation/hardhat-chai-matchers";
import "@nomiclabs/hardhat-etherscan";
import "@typechain/hardhat";
import "@nomiclabs/hardhat-ethers";
import { loadEnv } from "./utils/EnvLoader";


const { BSCSCAN_API_KEY, DEPLOYER_PRIVATE_KEY } = loadEnv();
const accounts = DEPLOYER_PRIVATE_KEY == undefined ? [] : [DEPLOYER_PRIVATE_KEY];

const config: HardhatUserConfig = {
  namedAccounts: {
    deployer: {
      default: 0,
      bscmain: "0x3BBFa3feDbb53323CD2beb754f20bDbb87D04bc1",
      bsctest: "0x49554923b9361e158Fb267B436f843a4f537D53a",
      wallaby: "0x49554923b9361e158Fb267B436f843a4f537D53a"
    },
    ownerAddress: {
      bscmain: "0x3BBFa3feDbb53323CD2beb754f20bDbb87D04bc1",
      bsctest: "0x49554923b9361e158Fb267B436f843a4f537D53a",
    },
    filTokenAddress: {
      bscmain: "0x0D8Ce2A99Bb6e3B7Db580eD848240e4a0F9aE153",
      bsctest: "0xCb12e617C17598EDa4ebC2e8a75cb0698feEE829",
      wallaby: "0xCb12e617C17598EDa4ebC2e8a75cb0698feEE829"
    },
    minterAddress: {
      bscmain: "0x37a1d1b504Ed06A9D5d494b82b8457cAf61eDAfC",
      bsctest: "0x8ace7f7e66f7546fa435380a640c08e9e77ad751",
      wallaby: "0x8ace7f7e66f7546fa435380a640c08e9e77ad751"
    },
    takerAddress: {
      bscmain: "0x49554923b9361e158Fb267B436f843a4f537D53a",
      bsctest: "0xd7bc572df81af1eef0b3b3ce6aba067b1b1677c9",
      wallaby: "0xd7bc572df81af1eef0b3b3ce6aba067b1b1677c9"
    },
    distributorAddress: {
      bscmain: "0xaEe4adf799632580882A8c23A3cf2B9154090c27",
      bsctest: "0x49554923b9361e158Fb267B436f843a4f537D53a",
      wallaby: "0x49554923b9361e158Fb267B436f843a4f537D53a"
    }
  },
 defaultNetwork: "hardhat",
 networks: {
    bscmain: {
      url: 'https://bsc-dataseed1.defibit.io/',
     chainId: 56,
      accounts,
    },
    bsctest: {
      url: 'https://data-seed-prebsc-2-s3.binance.org:8545',
      chainId: 97,
      accounts,
   },
   wallaby: {
     url: 'https://wallaby.node.glif.io/rpc/v0',
     chainId: 31415,
     accounts,
    }
  },

  solidity: {
    compilers: [
      {
        version: "0.8.9",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  etherscan: {
    apiKey: {
      bsc: `${BSCSCAN_API_KEY || ""}`,
      bscTestnet: `${BSCSCAN_API_KEY || ""}`
    },
  },
  typechain: {
    outDir: "typechain-types",
    target: "ethers-v5",
    alwaysGenerateOverloads: false, // should overloads with full signatures like deposit(uint256) be generated always, even if there are no overloads?
    externalArtifacts: ["externalArtifacts/*.json"], // optional array of glob patterns with external artifacts to process (for example external libs from node_modules)
    dontOverrideCompile: false, // defaults to false
  },
};

export default config;
