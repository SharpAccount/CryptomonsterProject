// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "CryptoMonster.sol";

contract LaunchSystem {
    
    enum Roles {
        Guest,
        Client,
        Investor,
        PrivateProvider,
        PublicProvider
    }

    struct User {
        string name;
        bytes32 password;
        Roles role;
    }

    CryptoMonster CMON = new CryptoMonster();

    mapping(address => User) registeredUsers;

    modifier onlyOwner {
        require(msg.sender == CMON.returnOwner(), "You don`t owner!");
        _;
    }

    constructor() {
        registeredUsers[0xdD870fA1b7C4700F2BD7f44238821C26f7392148] = User("Investor1", keccak256(abi.encode("p@55W0RD")), Roles.Investor);
        registeredUsers[0x583031D1113aD414F02576BD6afaBfb302140225] = User("Investor2", keccak256(abi.encode("844systemUser")), Roles.Investor);
        registeredUsers[0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB] = User("Best friend", keccak256(abi.encode("pa55WORD")), Roles.Investor);
    }

    function registration(string memory login, string memory password) public {
        require(registeredUsers[msg.sender].role == Roles.Guest, "You registered yet!");
        registeredUsers[msg.sender] = User(login, keccak256(abi.encode(password)), Roles.Client);
    }

}