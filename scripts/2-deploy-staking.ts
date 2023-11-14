import hre from 'hardhat';

const tokenManagerAddress = '0xbb568da12d7C2fa278F2422dc5C889d396A09F70';

async function main() {
  const [firstWallet] = await hre.ethers.getSigners();

  const owner = firstWallet.address;
  console.log('owner', owner);

  const StakingFactory = await hre.ethers.getContractFactory('Staking');
  const staking = await hre.upgrades.deployProxy(StakingFactory, [owner, tokenManagerAddress], {
    kind: 'uups',
  });
  const deployedAddress = await staking.getAddress();

  console.log('Staking deployed to:', deployedAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
