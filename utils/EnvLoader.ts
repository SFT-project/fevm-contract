import * as dotenv from "dotenv";

interface Env {
  BSCSCAN_API_KEY: string | undefined;
  DEPLOYER_PRIVATE_KEY: string | undefined;
}
const loadEnv = function (): Env {
  dotenv.config();

  return {
    BSCSCAN_API_KEY: process.env.BSCSCAN_API_KEY,
    DEPLOYER_PRIVATE_KEY: process.env.DEPLOYER_PRIVATE_KEY,
  };
};

export { loadEnv };
