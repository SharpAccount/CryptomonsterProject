// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CryptoMonster is ERC20("CryptoMonster", "CMON") {

    address public owner;
    uint public privatePhasePrice = 0.00075 * 10**18;
    //uint[] balacnes;

    constructor() {
         owner = msg.sender;   
        _mint(owner, 10000000);
    }

    function decimals() public view virtual override returns (uint8) {
        return 12;
    }

    function returnOwner() public view returns (address) {
        return owner;
    }
}