import hre from 'hardhat';

async function main() {
  const [ownerClient] = await hre.viem.getWalletClients();
  console.log('owner', ownerClient.account.address);

  const tokenManager = await hre.viem.deployContract('TokenManager', [ownerClient.account.address]);
  console.log('TokenManager deployed to: ', tokenManager.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
