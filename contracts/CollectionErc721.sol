//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//******************** ERC-721 Collection *************************/
// This is an ERC-721 contract that has permissions configured to 
// allow for minting of tokens by a designated external sale manager.
// The contract is deployed and then must be activated by the admin.
//
// The activation can only be done once and cannot be changed after.
// When activating, the admin must provide the URIs for the tokens
// that will be minted, along with the address of the sale manager.//
//******************************************************************/

contract CollectionErc721 is ERC721, AccessControl {
	bool private isActive;
	bytes32 public constant MINT_ADMIN_ROLE = keccak256("MINT_ADMIN_ROLE");
   	uint256 private _tokenIdCounter;
	uint256 public maxSupply;

    // Mapping from token ID to Uri
    mapping(uint256 => string) public uri;

// ******************************************* Constructor ************************************************************************
	constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) AccessControl() {	
		_grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
		_tokenIdCounter = 0;
	}
// ******************************************* Modifiers ************************************************************************

	modifier MustBeAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Only Admin Can Call This Function");
        _;
    }

	modifier MustBeMintAdmin() {
        require(hasRole(MINT_ADMIN_ROLE, _msgSender()), "Only Mint Admin Can Call This Function");
        _;
    }

// ******************************************* Setter Functions **************************************************************************
	function addAdmin(address _newAdminAddress) MustBeAdmin external {
		_grantRole(DEFAULT_ADMIN_ROLE, _newAdminAddress);
	}
	function removeAdmin(address _adminAddress) MustBeAdmin external {
		_revokeRole(DEFAULT_ADMIN_ROLE, _adminAddress);
	}
	function addMintAdmin(address _newMintAdminAddress) MustBeAdmin external {
		_grantRole(MINT_ADMIN_ROLE, _newMintAdminAddress);
	}
	function removeMintAdmin(address _mintAdminAddress) MustBeAdmin external {
		_revokeRole(MINT_ADMIN_ROLE, _mintAdminAddress);
	}

	function activateCollection(string[] memory _uris, address _saleManager) MustBeAdmin external {
		require(!isActive, "Sale is already active");
		require(_uris.length > 0, "URI array is empty");
		require(_saleManager != address(0), "Sale Manager address is invalid");
		maxSupply = _uris.length;
		for (uint256 i = 0; i < _uris.length; i++) {
			uri[i] = _uris[i];
		}
		_grantRole(MINT_ADMIN_ROLE, _saleManager);
		isActive = true;
	}

// ******************************************* Getter Functions **************************************************************************
    function tokenURI(uint256 tokenId) public override view returns (string memory) {
		return uri[tokenId];
    }
    function getNextTokenId() public view returns (uint256) {
        return _tokenIdCounter + 1;
    }

	function remainingSupply() public view returns (uint256) {
		return maxSupply - _tokenIdCounter;
	}

	// ******************************************* Mint Function **************************************************************************
     function mint(address _receiver) MustBeMintAdmin external returns(uint256) {
		require(isActive, "Sale is not active");
		require(_tokenIdCounter < maxSupply, "Sale has ended");
        _tokenIdCounter++;
        _mint(_receiver, _tokenIdCounter);
        return _tokenIdCounter;
    }	

	function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}