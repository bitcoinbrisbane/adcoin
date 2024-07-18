const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("CoinModule", (m) => {
  const coin = m.contract("AdCoin");

  return { coin };
});
