import { ethers } from "hardhat";

async function main() {
  const [owner, acct1, acct2, acct3] = await ethers.getSigners();
  const MultiSig = await ethers.getContractFactory("MultiSig");
  const multiSig = await MultiSig.deploy(
    [owner.address, acct1.address,acct2.address],
    2
  );
  await multiSig.deployed()
  console.log(multiSig.address)
  const multiSigAddress = multiSig.address;
  
  
  const deployedMultiSig = await ethers.getContractAt("IMultiSig",multiSigAddress);
  console.log(await deployedMultiSig.getAdmins());

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});