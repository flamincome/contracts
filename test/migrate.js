const { expect } = require("chai");

const daoAddress = "0x4B827D771456Abd5aFc1D05837F915577729A751"

async function getUSDTAssets(addr) {
  const [owner] = await ethers.getSigners();
  const usdt = new ethers.Contract('0xdAC17F958D2ee523a2206206994597C13D831ec7', [
    "function balanceOf(address who) public view returns (uint)",
  ], owner)
  const usdtBalance = await usdt.balanceOf(addr)
  return usdtBalance
}


it("migration works fine", async () => {
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [daoAddress]
  })
  const dao = await ethers.provider.getSigner(daoAddress);
  const [owner] = await ethers.getSigners();
  await owner.sendTransaction({
    to: daoAddress,
    value: ethers.utils.parseEther("1.0")
  });

  const vaultY = new ethers.Contract('0x0461eEFF7C856020E574c0c364FE968Ca06BCc0F', [
    "function priceE18() public view returns (uint)",
  ], dao);
  const newStrat = new ethers.Contract('0xb8d6471cA573C92c7096Ab8600347F6a9Fe268a5', [
    "function D(uint256 _ne18) public",
  ], dao);

  const e18 = ethers.BigNumber.from(10).pow(18)

  const prevPrice = await vaultY.priceE18();
  console.log('prevPrice', prevPrice.toString())
  console.log('usdt before', (await getUSDTAssets(newStrat.address)).toString());
  //await newStrat.D('1150000000000000000'); // Withdraw 15% from aave
  console.log('usdt after aave withdraw', (await getUSDTAssets(newStrat.address)).toString());
  await newStrat.D('0'); // Claim
  await newStrat.D('4999999999999999999'); // Sell 100% alcx
  //await newStrat.D('2999999999999999999'); // Deposit 100% on alcx
  console.log('usdt after', (await getUSDTAssets(newStrat.address)).toString());
  const afterPrice = await vaultY.priceE18();
  console.log('afterPrice', afterPrice.toString())
})