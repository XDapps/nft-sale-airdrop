import { ethers } from "hardhat";
import { expect } from "chai";

let mockAirdrop = "";
let saleManager = "";
let erc721Collection = "";

describe("Test Airdrop Native", async function () {
	it("Deploy, Activate, Test", async function () {
		const [deployer, user1] = await ethers.getSigners();

		//****************Deploy Contracts****************//
		const CollectionErc721Factory = await ethers.getContractFactory("CollectionErc721");
		const CollectionSaleManagerFactory = await ethers.getContractFactory("CollectionSaleManager");
		const MockAirDropTokenFactory = await ethers.getContractFactory("MockAirDropToken");

		const collectionName = "ERC-721 Airdrop Collection";
		const collectionSymbol = "EAC";
		const collectionContract = await CollectionErc721Factory.deploy(collectionName, collectionSymbol);
		erc721Collection = await collectionContract.getAddress();

		expect(await collectionContract.name()).to.equal(collectionName);
		expect(await collectionContract.symbol()).to.equal(collectionSymbol);

		const saleManagerContract = await CollectionSaleManagerFactory.deploy(erc721Collection, user1.address);
		saleManager = await saleManagerContract.getAddress();

		const airdropName = "MockAirDropToken";
		const airdropSymbol = "MAT";

		const qtyPerClaim = ethers.parseUnits("10000", 18);
		const airdropContract = await MockAirDropTokenFactory.deploy(airdropName, airdropSymbol, erc721Collection, qtyPerClaim);
		mockAirdrop = await airdropContract.getAddress();

		//****************Activate Collection****************//
		const uris = ["uri1", "uri2"];
		const maxSupplyBefore = await collectionContract.maxSupply();
		expect(maxSupplyBefore).to.equal(0);
		await collectionContract.activateCollection(uris, saleManager);
		const maxSupplyAfter = await collectionContract.maxSupply();
		expect(maxSupplyAfter).to.equal(uris.length);

		//*****************Activate Sale Manager************//
		const priceEach = ethers.parseUnits("100", 18);
		const paymentToken = "0x0000000000000000000000000000000000000000"
		await saleManagerContract.activateSale(paymentToken, priceEach);

		//********************* Buy Token *********************//
		await saleManagerContract.buyToken({ value: priceEach });

		const nftBalanceOfUser = await collectionContract.balanceOf(deployer.address);
		expect(nftBalanceOfUser).to.equal(1);

		const nativeBalanceOfUser1 = await deployer.provider.getBalance(user1.address);
		expect(nativeBalanceOfUser1).to.equal(ethers.parseUnits("10100", 18));

		//************************ Claim Airdrop ***************************//

		await airdropContract.claimAirdrop(1);
		const airdropBalanceOfUser = await airdropContract.balanceOf(deployer.address);
		expect(airdropBalanceOfUser).to.equal(qtyPerClaim);

		//********************* Try to Claim Airdrop Again ******************//
		expect(airdropContract.claimAirdrop(1)).to.be.revertedWith("Token already claimed");

	});
});
