//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//************ Mock Stable Coin ************************************/
// This is a mock ERC-20 stable coin contract to be used in testing
// of an ERC-721 token sale.
//******************************************************************/

contract MockStableCoin is ERC20 {
    // ******************************************* Constructor ************************************************************************
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(address _receiver, uint256 _amount) external {
        _mint(_receiver, _amount);
    }
}
