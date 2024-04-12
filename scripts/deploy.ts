import { ethers } from "hardhat";

async function main() {
	let saleManager = "";
	let erc721Collection = "";
	let disbursementAddress = "";

	try {
		const CollectionErc721Factory = await ethers.getContractFactory("CollectionErc721");
		const CollectionSaleManagerFactory = await ethers.getContractFactory("CollectionSaleManager");
		const collectionName = "ERC-721 Airdrop Collection";
		const collectionSymbol = "EAC";
		const collectionContract = await CollectionErc721Factory.deploy(collectionName, collectionSymbol);
		erc721Collection = await collectionContract.getAddress();

		const saleManagerContract = await CollectionSaleManagerFactory.deploy(erc721Collection, disbursementAddress);
		saleManager = await saleManagerContract.getAddress();


	} catch (error) {
		console.error("Error deploying contract", error);
	}
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
