// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import "CryptoMonster.sol";
import "hardhat/console.sol";

contract CryptoMonster is ERC20("CryptoMonster", "CMON") {
    
    address public owner;

    uint public privatePhasePrice = 0.00075 * 10**18;
    uint256 _totalSupply;

    constructor() {
         owner = msg.sender;   
        _mint(owner, 10000000);
    }

    function decimals() public view virtual override returns (uint8) {
        return 12;
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address _owner = msg.sender;
        _approve(_owner, spender, amount);
        return true;
    }

    function transferFrom(uint amount, address _from, address _to, uint tokenType) external {
        //require(registeredUsers[])
        //if (tokenType == 0)
    }

    // function _approve(address owner, address spender, uint256 amount) internal virtual {
    //     require(owner != address(0), "ERC20: approve from the zero address");
    //     require(spender != address(0), "ERC20: approve to the zero address");

    //     _allowances[owner][spender] = amount;
    //     emit Approval(owner, spender, amount);
    // }

}

contract LaunchSystem {
    
    enum Roles {
        Guest,
        Client,
        Investor,
        Supporter,
        PrivateProvider,
        PublicProvider,
        Owner
    }

    struct User {
        string login;
        address currentAddress;
        bool isInWhitelist;
        uint seedbalance;
        uint privatebalance;
        uint publicbalance;
        Roles role;
    }

    CryptoMonster CMON = new CryptoMonster();
    uint timeStart;
    uint timeDif;
    uint timeSystem; //block.timestamp + timeDif
    string signedPerson; //signed person login

    mapping(address => User) private registeredUsers;
    mapping(string => address) private logsAddresses;
    mapping(string => bytes32) private logsPasses;


    modifier onlyOwner {
        require(msg.sender == registeredUsers[msg.sender].currentAddress, "You don`t owner!");
        _;
    }
    modifier onlyProvider(string memory _login, uint providerCode) {
        if(providerCode == 0) {
            require(registeredUsers[logsAddresses[_login]].role == Roles.PrivateProvider, "You`re not private provider!");
        } else if (providerCode == 1) {
            require(registeredUsers[logsAddresses[_login]].role == Roles.PublicProvider, "You`re not public provider!");
        } else if (providerCode == 2) {
            require((registeredUsers[logsAddresses[_login]].role == Roles.PublicProvider) || (registeredUsers[logsAddresses[_login]].role == Roles.PrivateProvider), "You`re not provider!");
        }
        _;
    }
    modifier onlyRegistered() {
        require(bytes(signedPerson).length > 0, "You must sign in your account or register it!");
        _;
    }

    constructor() {

        registeredUsers[msg.sender] = User("Owner", msg.sender, true, 0, 0, 0, Roles.Owner);
        logsPasses["Owner"] = keccak256(abi.encode("admin"));
        logsAddresses["Owner"] = msg.sender;

        registeredUsers[0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB] = User("Private Provider", 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB, true, 0, 0, 0, Roles.PrivateProvider);
        logsPasses["Private Provider"] = keccak256(abi.encode("admin"));
        logsAddresses["Private Provider"] = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;

        registeredUsers[0x583031D1113aD414F02576BD6afaBfb302140225] = User("Public Provider", 0x583031D1113aD414F02576BD6afaBfb302140225, true, 0, 0, 0, Roles.PublicProvider);
        logsPasses["Public Provider"] = keccak256(abi.encode("public"));
        logsAddresses["Public Provider"] = 0x583031D1113aD414F02576BD6afaBfb302140225;

        registeredUsers[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = User("Investor1", 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, true, 0, 0, 0, Roles.Investor);//300000 * CMON.decimals()
        logsPasses["Inv1"] = keccak256(abi.encode("p@55W0RD"));
        logsAddresses["Investor1"] = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

        registeredUsers[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = User("Investor2", 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, true, 0, 0, 0, Roles.Investor);//400000 * CMON.decimals()
        logsPasses["Inv2"] = keccak256(abi.encode("844systemUser"));
        logsAddresses["Investor2"] = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

        registeredUsers[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = User("Best friend", 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, true, 0, 0, 0, Roles.Investor);//200000 * CMON.decimals()
        logsPasses["Friend"] = keccak256(abi.encode("pa55WORD"));
        logsAddresses["Best friend"] = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;

        timeStart = block.timestamp;
        timeSystem = block.timestamp;
        timeDif = 0;
    }

    function signIn(string memory _login, string memory password) public {
        require(logsPasses[_login] == keccak256(abi.encode(password)), "Wrong login or password!");
        require(bytes(signedPerson).length == 0, "You`re already signed!");
        signedPerson = _login;
    }
    function signUp(string memory login, string memory password) public {
        require(registeredUsers[logsAddresses[login]].role == Roles.Guest, "This login is busy!");
        registeredUsers[logsAddresses[login]] = User(login, msg.sender, false, 0, 0, 0, Roles.Client);
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