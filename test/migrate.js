const { expect } = require("chai");

const daoAddress = "0x4B827D771456Abd5aFc1D05837F915577729A751"

async function getUSDTAssets(addr) {
  const usdt = new ethers.Contract('0xdAC17F958D2ee523a2206206994597C13D831ec7', [
    "function balanceOf(address owner)",
  ])
  const aUSDT = new ethers.Contract('0x3Ed3B47Dd13EC9a98b44e6204A523E766B225811', [
    "function balanceOf(address owner)",
  ])
  return (await usdt.balanceOf(addr)) + (await aUSDT.balanceOf(addr))
}

it("migration works fine", async () => {
  const Mig = await ethers.getContractFactory("MigrateStrat");
  const mig = await Mig.deploy();
  const [owner, addr1] = await ethers.getSigners();
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [daoAddress]
  })
  const dao = await ethers.provider.getSigner(daoAddress);
  await owner.sendTransaction({
    to: daoAddress,
    value: ethers.utils.parseEther("1.0")
  });

  const currentStrat = new ethers.Contract('0x5D6DF808Be06d77c726001b1B3163C3294cb8D08', [
    "function setGovernance(address _governance)",
  ], dao);
  const newStrat = new ethers.Contract('0xb8d6471cA573C92c7096Ab8600347F6a9Fe268a5', [
    "function setGovernance(address _governance)",
  ], dao);
  await newStrat.setGovernance(mig.address);
  await currentStrat.setGovernance(mig.address);


  const allUSDT = await getUSDTAssets(currentStrat.address)
  expect(await getUSDTAssets(newStrat.address)).to.be(0)
  console.log(currentUSDT)
  await mig.migrate();
  expect(await getUSDTAssets(newStrat.address)).to.be(allUSDT)
  expect(await getUSDTAssets(currentStrat.address)).to.be(0)
})