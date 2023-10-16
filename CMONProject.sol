// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "CryptoMonster.sol";
import "hardhat/console.sol";

contract LaunchSystem {
    
    enum Roles {
        Guest,
        Client,
        Investor,
        Supporter,
        PrivateProvider,
        PublicProvider
    }

    struct User {
        Roles role;
        address currentWallet;
    }

    CryptoMonster CMON = new CryptoMonster();
    uint timeStart;
    uint timeDif;
    uint timeSystem; //block.timestamp + timeDif
    string signedPerson;

    mapping(string => User) private registeredUsers;
    mapping(string => bytes32) private logsPasses;


    modifier onlyOwner {
        require(msg.sender == CMON.returnOwner(), "You don`t owner!");
        _;
    }
    modifier onlyProvider(string memory login, uint providerCode) {
        if(providerCode == 0) {
            require(registeredUsers[login].role == Roles.PrivateProvider, "You`re not private provider!");
        } else if (providerCode == 1) {
            require(registeredUsers[login].role == Roles.PublicProvider, "You`re not public provider!");
        } else if (providerCode == 2) {
            require((registeredUsers[login].role == Roles.PublicProvider) || (registeredUsers[login].role == Roles.PrivateProvider), "You`re not provider!");
        }
        _;
    }
    modifier onlyRegistered() {
        require(bytes(signedPerson).length > 0, "You must sign in your account or register it!");
        _;
    }

    constructor() {
        registeredUsers["Inv1"] = User(Roles.Investor, 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        logsPasses["Inv1"] = keccak256(abi.encode("p@55W0RD"));

        registeredUsers["Inv2"] = User(Roles.Investor, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
        logsPasses["Inv2"] = keccak256(abi.encode("844systemUser"));

        registeredUsers["Friend"] = User(Roles.Investor, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
        logsPasses["Friend"] = keccak256(abi.encode("pa55WORD"));

        timeStart = block.timestamp;
        timeSystem = block.timestamp;
        timeDif = 0;

        CMON.approve(registeredUsers["Inv1"].currentWallet, 300000);
        CMON.approve(registeredUsers["Inv2"].currentWallet, 400000);
        CMON.approve(registeredUsers["Friend"].currentWallet, 200000);

        CMON.transferFrom(CMON.owner(), registeredUsers["Inv1"].currentWallet, 300000);
        CMON.transferFrom(CMON.owner(), registeredUsers["Inv2"].currentWallet, 400000);
        CMON.transferFrom(CMON.owner(), registeredUsers["Friend"].currentWallet, 200000);
    }

    function signIn(string memory _login, string memory password) public {
        require(logsPasses[_login] == keccak256(abi.encode(password)), "Wrong login or password!");
        require(bytes(signedPerson).length == 0, "You`re already signed!");
        signedPerson = _login;
    }
    function signUp(string memory login, string memory password) public {
        require(registeredUsers[login].role == Roles.Guest, "This login is busy!");
        registeredUsers[login] = User(Roles.Client, msg.sender);
        logsPasses[login] = keccak256(abi.encode(password));
    }
    function signOut() public onlyRegistered() {
        signedPerson = "";
    }
    function checkSystemLifeTime() public returns(uint) {
        resetTime();
        console.log(timeDif);
        return timeDif;
    }
    function addTime(string memory signed) public onlyRegistered() onlyProvider(signed, 3) {
        timeSystem += 1 minutes;
        resetTime();
    }


    function resetTime() private {
        timeDif = block.timestamp - timeStart;
        timeSystem = block.timestamp + timeDif;
    }

}