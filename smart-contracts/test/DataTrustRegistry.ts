import { expect } from "chai";
import { ethers } from "hardhat";

describe("DataTrustRegistry", function () {
  const datasetId = ethers.id("FINANCIAL-001");
  const datasetHash = ethers.id("file contents v1");
  const reportHash = ethers.id("report v1");

  async function deploy() {
    const [owner, other] = await ethers.getSigners();
    const Registry = await ethers.getContractFactory("DataTrustRegistry");
    const registry = await Registry.deploy();
    return { registry, owner, other };
  }

  it("registers a dataset and stores its hashes", async function () {
    const { registry, owner } = await deploy();
    await registry.registerDataset(datasetId, datasetHash, reportHash);

    const record = await registry.getDataset(datasetId);
    expect(record.datasetHash).to.equal(datasetHash);
    expect(record.reportHash).to.equal(reportHash);
    expect(record.owner).to.equal(owner.address);
    expect(await registry.isRegistered(datasetId)).to.equal(true);
  });

  it("verifies an unchanged dataset and detects a modified one", async function () {
    const { registry } = await deploy();
    await registry.registerDataset(datasetId, datasetHash, reportHash);

    expect(await registry.verifyDataset(datasetId, datasetHash)).to.equal(true);
    expect(await registry.verifyDataset(datasetId, ethers.id("tampered"))).to.equal(false);
    expect(await registry.verifyReport(datasetId, reportHash)).to.equal(true);
  });

  it("rejects duplicate registration", async function () {
    const { registry, other } = await deploy();
    await registry.registerDataset(datasetId, datasetHash, reportHash);

    await expect(
      registry.connect(other).registerDataset(datasetId, datasetHash, reportHash)
    ).to.be.revertedWithCustomError(registry, "AlreadyRegistered");
  });

  it("reports unregistered datasets", async function () {
    const { registry } = await deploy();
    expect(await registry.isRegistered(datasetId)).to.equal(false);
    await expect(
      registry.verifyDataset(datasetId, datasetHash)
    ).to.be.revertedWithCustomError(registry, "NotRegistered");
  });
});
