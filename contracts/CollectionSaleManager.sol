//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//************ Collection Sale Manager *****************************/
// This is a contract to manage the sale of NFT tokens in an ERC-721
// collection. It allows the admin to activate the sale, set the
// price of each token, and set a disbursement address. The contract
// can accept payment in the native currency, or any ERC-20 token.
//******************************************************************/

interface ICollection {
    function remainingSupply() external view returns (uint256);
    function mint(address _receiver) external returns (uint256);
}

contract CollectionSaleManager is AccessControl {
    address public collectionAddress;
    address private _disbursementAddress;
    address public paymentToken;
    uint256 public priceEach;

    event SaleActivated(address collectionAddress, address paymentToken, uint256 priceEach);
    event TokenSale(address indexed buyer, uint256 indexed tokenId);

    // ******************************************* Constructor ************************************************************************
    constructor(address _collectionAddress, address _disbursementAddy) AccessControl() {
        require(_disbursementAddy != address(0), "Disbursement Address is invalid");
        require(_isERC721Token(_collectionAddress), "Collection Address is not ERC721");
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        collectionAddress = _collectionAddress;
        _disbursementAddress = _disbursementAddy;
    }
    // ******************************************* Modifiers ************************************************************************

    modifier MustBeAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Only Admin Can Call This Function");
        _;
    }

    // ******************************************* Setter Functions **************************************************************************
    function addAdmin(address _newAdminAddress) external MustBeAdmin {
        _grantRole(DEFAULT_ADMIN_ROLE, _newAdminAddress);
    }

    function removeAdmin(address _adminAddress) external MustBeAdmin {
        _revokeRole(DEFAULT_ADMIN_ROLE, _adminAddress);
    }

    function activateSale(address _paymentToken, uint256 _priceEach) external MustBeAdmin {
        require(ICollection(collectionAddress).remainingSupply() > 0, "Collection is not setup");
        require(_priceEach > 0, "Price Each is invalid");
        paymentToken = _paymentToken;
        priceEach = _priceEach;
        emit SaleActivated(collectionAddress, _paymentToken, priceEach);
    }

    function setDisbursementAddress(address _disbursementAddy) external MustBeAdmin {
        require(_disbursementAddress != address(0), "Disbursement Address is invalid");
        _disbursementAddress = _disbursementAddy;
    }
    // ******************************************* Purchase Functions **************************************************************************
    function buyToken() external payable returns (uint256) {
        require(priceEach > 0, "Sale is not active");
        ICollection collection = ICollection(collectionAddress);
        uint256 qtyRemaining = collection.remainingSupply();
        require(qtyRemaining > 0, "Collection is sold out");
        _processPayment();
        uint256 tokenId = collection.mint(_msgSender());
        require(tokenId > 0, "Minting failed");
        emit TokenSale(_msgSender(), tokenId);
        return tokenId;
    }

    function _processPayment() private {
        if (paymentToken == address(0)) {
            require(msg.value >= priceEach, "Insufficient payment");
            (bool success, ) = _disbursementAddress.call{ value: priceEach }("");
            require(success, "Payment failed");
        } else {
            IERC20 erc20 = IERC20(paymentToken);
            require(erc20.balanceOf(_msgSender()) >= priceEach, "Insufficient balance");
            require(erc20.allowance(_msgSender(), address(this)) >= priceEach, "Insufficient allowance");
            require(erc20.transferFrom(_msgSender(), _disbursementAddress, priceEach), "Payment failed");
        }
    }

    // ************************ Helpers Functions ****************************/

    function _isERC721Token(address addressToCheck) private view returns (bool) {
        bytes4 interfaceId = type(IERC721).interfaceId;
        IERC721 tokenContract = IERC721(addressToCheck);
        return tokenContract.supportsInterface(interfaceId);
    }
}
