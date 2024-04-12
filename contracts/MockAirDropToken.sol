//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//************ Mock Airdrop Token *********************************/
// This is a mock contract showing how an ERC-20 airdrop token can be 
// claimed by the owners of NFT tokens in a specific collection.
//******************************************************************/

contract MockAirDropToken is ERC20 {
	address public collectionAddress;
	uint256 public qtyPerClaim;

	mapping (uint256 => bool) public isClaimed;

    // ****************************** Constructor ****************************
    constructor(string memory _name, string memory _symbol, address _collectionAddress, uint256 _qtyPerClaim) ERC20(_name, _symbol) {
		collectionAddress = _collectionAddress;
		qtyPerClaim = _qtyPerClaim;
	}

    // ****************************** Claim Function ****************************
	function claimAirdrop(uint256 _tokenId) external {
		require(!isClaimed[_tokenId], "Token already claimed");
		address tokenOwner = IERC721(collectionAddress).ownerOf(_tokenId);
		require(tokenOwner == msg.sender, "You are not the owner of this token");
		_mint(msg.sender, qtyPerClaim);
		isClaimed[_tokenId] = true;
	}
	
}
