import hre from 'hardhat';

const tokenManagerAddress = '0xbb568da12d7C2fa278F2422dc5C889d396A09F70';

const EMP_ADDRESS = '0x62104f305C22F4F0Fc3D33aDfC185808F20192f0';
const POKA_ADDRESS = '0xa9875760eCC0b1f3637984bFF26a97799B11fB11';
const BEATS_ADDRESS = '0xE6D3856f65e82c7a255E75D2D1dA3aeE70E38376';

async function main() {
  const tokenManager = await hre.viem.getContractAt('TokenManager', tokenManagerAddress);

  const publicClient = await hre.viem.getPublicClient();

  const hash1 = await tokenManager.write.addToken([EMP_ADDRESS]);
  const receipt1 = await publicClient.waitForTransactionReceipt({ hash: hash1 });
  console.log('transactionHash1', receipt1.transactionHash);

  const hash2 = await tokenManager.write.addToken([POKA_ADDRESS]);
  const receipt2 = await publicClient.waitForTransactionReceipt({ hash: hash2 });
  console.log('transactionHash2', receipt2.transactionHash);

  const hash3 = await tokenManager.write.addToken([BEATS_ADDRESS]);
  const receipt3 = await publicClient.waitForTransactionReceipt({ hash: hash3 });
  console.log('transactionHash3', receipt3.transactionHash);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
