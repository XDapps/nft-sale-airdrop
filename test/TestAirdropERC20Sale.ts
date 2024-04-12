import { ethers, upgrades } from "hardhat";
import { expect } from "chai";


let mockStable = "";
let mockAirdrop = "";
let saleManager = "";
let erc721Collection = "";

describe("Test Airdrop ERC-20", async function () {
	it("Deploy, Activate, Test", async function () {
		const [deployer, user1] = await ethers.getSigners();

		//****************Deploy Contracts****************//
		const CollectionErc721Factory = await ethers.getContractFactory("CollectionErc721");
		const CollectionSaleManagerFactory = await ethers.getContractFactory("CollectionSaleManager");
		const MockAirDropTokenFactory = await ethers.getContractFactory("MockAirDropToken");
		const MockStableCoinFactory = await ethers.getContractFactory("MockStableCoin");

		const collectionName = "ERC-721 Airdrop Collection";
		const collectionSymbol = "EAC";
		const collectionContract = await CollectionErc721Factory.deploy(collectionName, collectionSymbol);
		erc721Collection = await collectionContract.getAddress();

		expect(await collectionContract.name()).to.equal(collectionName);
		expect(await collectionContract.symbol()).to.equal(collectionSymbol);

		const saleManagerContract = await CollectionSaleManagerFactory.deploy(erc721Collection, user1.address);
		saleManager = await saleManagerContract.getAddress();

		const stableName = "MockStableCoin";
		const stableSymbol = "MSC";

		const stableCoinContract = await MockStableCoinFactory.deploy(stableName, stableSymbol);
		mockStable = await stableCoinContract.getAddress();

		expect(await stableCoinContract.name()).to.equal(stableName);
		expect(await stableCoinContract.symbol()).to.equal(stableSymbol);

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
		await saleManagerContract.activateSale(mockStable, priceEach);

		//****************Mint Mock Stable Coins************//
		await stableCoinContract.mint(deployer.address, ethers.parseUnits("1000", 18));

		//********************* Buy Token *********************//
		await stableCoinContract.approve(saleManager, ethers.parseUnits("100", 18));
		await saleManagerContract.buyToken();

		const nftBalanceOfUser = await collectionContract.balanceOf(deployer.address);
		expect(nftBalanceOfUser).to.equal(1);

		const stableBalanceOfUser = await stableCoinContract.balanceOf(deployer.address);
		expect(stableBalanceOfUser).to.equal(ethers.parseUnits("900", 18));

		const stableBalanceOfUser1 = await stableCoinContract.balanceOf(user1.address);
		expect(stableBalanceOfUser1).to.equal(ethers.parseUnits("100", 18));

		//************************ Claim Airdrop ***************************//

		await airdropContract.claimAirdrop(1);
		const airdropBalanceOfUser = await airdropContract.balanceOf(deployer.address);
		expect(airdropBalanceOfUser).to.equal(qtyPerClaim);

		//********************* Try to Claim Airdrop Again ******************//
		expect(airdropContract.claimAirdrop(1)).to.be.revertedWith("Token already claimed");
	});
});
