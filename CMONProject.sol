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

    // enum Statuses {
    //     Unsigned,
    //     Signed
    // }

    struct User {
        Roles role;
        // Statuses status;
    }

    CryptoMonster CMON = new CryptoMonster();
    uint timeNow = block.timestamp;
    uint timeStart;
    uint timeDif;
    uint timeSystem; //timeNow + timeDif
    string signedPerson;

    mapping(string => User) private registeredUsers;
    mapping(string => bytes32) private logsPasses;
    // mapping(string => Statuses) private logsStatuses;

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

    constructor() {
        // registeredUsers[0xdD870fA1b7C4700F2BD7f44238821C26f7392148] = User("Investor1", keccak256(abi.encode("p@55W0RD")), Roles.Investor);
        // registeredUsers[0x583031D1113aD414F02576BD6afaBfb302140225] = User("Investor2", keccak256(abi.encode("844systemUser")), Roles.Investor);
        // registeredUsers[0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB] = User("Best friend", keccak256(abi.encode("pa55WORD")), Roles.Investor);
        timeStart = timeNow;
        timeSystem = timeNow;
        timeDif = 0;
    }

    // function signOut() public onlySigned() {

    // }
    function signIn(string memory _login, string memory password) public {
        require(logsPasses[_login] == keccak256(abi.encode(password)), "Wrong login or password!");
        //logsStatuses[_login] = Statuses.Signed;
        signedPerson = _login;
    }
    function signUp(string memory login, string memory password) public {
        require(registeredUsers[login].role == Roles.Guest, "Try another login!");
        registeredUsers[login] = User(Roles.Client);
        logsPasses[login] = keccak256(abi.encode(password));
    }
    function checkSystemLifeTime() public returns(uint) {
        setTime();
        console.log(timeDif);
        return timeDif;
    }
    function addTime(string memory signed) public onlyProvider(signed, 3) {
        timeSystem += 1 minutes;
        setTime();
    }
    function setTime() private {
        timeDif = timeNow - timeStart;
        timeSystem = timeNow + timeDif;
    }

}