// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract LaunchSystem is ERC20("CryptoMonster", "CMON") {

    enum Phases {
        Seed,
        Private,
        Public
    }

    enum Roles {
        User,
        PrivateProvider,
        PublicProvider,
        Owner
    }

    struct User {
        string login;
        address wallet;
        bool isInWhitelist;
        uint256 seedBalance;
        uint256 privateBalance;
        uint256 publicBalance;
        Roles role;
    }

    struct Whitelist {
        string login;
        address wallet;
        bool isApproved;
    }

    uint256 timeSystem = block.timestamp; //block.timestamp + timeDif
    uint256 timeStart = block.timestamp;
    uint256 timeDif = 0; 
    uint256 currentPrice;
    uint256 currentMaxAmount;
    string signedPerson; //signed person login
    Phases phase;

    Whitelist[] private whitelistRequires;
    Whitelist[] private approvedRequires;

    mapping(address => User) private registeredUsers;
    mapping(string => address) private logsAddresses;
    mapping(string => bytes32) private logsPasses;
    mapping(Phases => uint) private prices;
    mapping(Phases => uint) private maxAmounts;


    modifier onlyThisRole(Roles _role) {
        require(_role == registeredUsers[msg.sender].role, "You don`t have permissions to do this!");
        _;
    }

    modifier onlyInThisPhase(Phases _phase) {
        require(phase == _phase, "This phase isn`t already started or finished!");
        _;
    }


    constructor() {  
        prices[Phases.Private] = 0.00075 ether;
        prices[Phases.Public] = 0.001 ether;

        maxAmounts[Phases.Private] = 100_000 * 10 ** decimals();
        maxAmounts[Phases.Public] = 5_000 * 10 ** decimals();

        registeredUsers[msg.sender] = User("owner", msg.sender, true, 0, 0, 0, Roles.Owner);
        logsPasses["owner"] = keccak256(abi.encode("123"));
        logsAddresses["owner"] = msg.sender;

        registeredUsers[0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB] = User("priv prov", 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB, true, 0, 0, 0, Roles.PrivateProvider);
        logsPasses["priv prov"] = keccak256(abi.encode("123"));
        logsAddresses["priv prov"] = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;

        registeredUsers[0x583031D1113aD414F02576BD6afaBfb302140225] = User("pub prov", 0x583031D1113aD414F02576BD6afaBfb302140225, true, 0, 0, 0, Roles.PublicProvider);
        logsPasses["pub prov"] = keccak256(abi.encode("123"));
        logsAddresses["pub prov"] = 0x583031D1113aD414F02576BD6afaBfb302140225;

        registeredUsers[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = User("inv1", 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, true, 300_000 * 10**decimals(), 0, 0, Roles.User);//300000 * CMON.decimals()
        logsPasses[string("inv1")] = keccak256(abi.encode("123"));
        logsAddresses[string("inv1")] = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

        registeredUsers[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = User("inv2", 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, true, 400_000 * 10**decimals(), 0, 0, Roles.User);//400000 * CMON.decimals()
        logsPasses["inv2"] = keccak256(abi.encode("123"));
        logsAddresses["inv2"] = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

        registeredUsers[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = User("friend", 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, true, 200_000 * 10**decimals(), 0, 0, Roles.User);//200000 * CMON.decimals()
        logsPasses["friend"] = keccak256(abi.encode("123"));
        logsAddresses["friend"] = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;

        _mint(msg.sender, 9_100_000 * 10 ** decimals());
        _resetTime();
    }


    function signUp(string memory login, string memory password) public {
        require(logsAddresses[login] == address(0), "This login is busy!");
        require(registeredUsers[logsAddresses[login]].wallet == address(0));
        logsAddresses[login] = msg.sender;
        logsPasses[login] = keccak256(abi.encode(password));
        registeredUsers[logsAddresses[login]] = User(login, msg.sender, false, 0, 0, 0, Roles.User);
    }

    function checkSystemLifeTime() public returns(uint) {
        uint timeLife = _resetTime();
        console.log(timeLife);
        return  timeLife;
    }

    function addMinute() public {
        timeDif += 60;
        _resetTime();
    }

    function askForWhitelistInvite() public onlyInThisPhase(Phases.Seed) {
        // require(logsAddresses[login] != address(0), "Don`t find your login!");
        //require(!registeredUsers[msg.sender].whitelist, unicode"Вы уже в вайтлисте");
        // require(registeredUsers[wallet].currentAddress != address(0), "Don`t find your address!");
        // asksForInviting[wallet] = login;
    }

    function acceptInviteRequests(string memory requesterLog, bool isAccepted) public onlyInThisPhase(Phases.Seed) onlyThisRole(Roles.PrivateProvider) {
        require(logsAddresses[requesterLog] != address(0), "Didn`t find requester`s login!");
        if (isAccepted == true) {
            registeredUsers[logsAddresses[requesterLog]].isInWhitelist = true;
        } else {
            
        }
    }

    function giveReward(address _to, address _from, uint8 amount) public onlyThisRole(Roles.PublicProvider) {
        // место под require с approve
        require(registeredUsers[_from].seedBalance >= amount, "You don`t have enough tokens!");
        registeredUsers[_from].seedBalance -= amount;
        registeredUsers[_to].seedBalance += amount;
    }

    function changeTokenCost(uint8 costValue) public onlyThisRole(Roles.PublicProvider) onlyInThisPhase(Phases.Public) {
        currentPrice = costValue;
    }

    function buyToken(uint8 amount) public payable {
        require(currentPrice * amount >= registeredUsers[logsAddresses[signedPerson]].wallet.balance, unicode"У вас недостаточно eth!");
        if (phase == Phases.Private) {
            require(registeredUsers[msg.sender].isInWhitelist == true, "Free sale not started");
            //transfer
            // registeredUsers[logsAddresses[signedPerson]].currentAddress.Transfer(address(this.balance), );
        }
    }

    function signIn(string memory login, string memory password) public view returns(User memory) {
        require(logsPasses[login] == keccak256(abi.encode(password)), "Wrong login or password!");
        return registeredUsers[logsAddresses[login]];
    }

    function decimals() public view virtual override returns (uint8) {
        return 12;
    }

    function _transfer(address from, address to, uint256 amount, uint8 tokenType) private {
        require(to != address(0), unicode"Нельзя перевести токены на несуществующий адрес!");
        currentPrice ++;//delete

        if (tokenType == 0) {
            require(registeredUsers[from].seedBalance >= amount, unicode"Не хватает seed токенов!");
            registeredUsers[from].seedBalance -= amount;
            registeredUsers[to].seedBalance += amount;
        } else if (tokenType == 1) {
            require(registeredUsers[from].privateBalance >= amount, unicode"Не хватает private токенов!");
            registeredUsers[from].privateBalance -= amount;
            registeredUsers[to].privateBalance += amount;
        } else if (tokenType == 2) {
            require(registeredUsers[from].publicBalance >= amount, unicode"Не хватает public токенов!");
            registeredUsers[from].publicBalance -= amount;
            registeredUsers[to].publicBalance += amount;
        }
        
        //emit Transfer(from, to, amount);
    }

    function _resetTime() private returns(uint256) {
        timeSystem = block.timestamp + timeDif;
        uint timeLife = (timeSystem - timeStart);
        if (timeLife > 300 && phase != Phases.Private) {
            phase = Phases.Private; 
            _makePhaseConditions(phase);
        }
        else if (timeLife > 900 && phase != Phases.Public) {
            phase = Phases.Public;
            _makePhaseConditions(phase);
        }
        return timeLife;
    }

    function _makePhaseConditions(Phases _phase) private {

        currentPrice = prices[_phase];
        currentMaxAmount = maxAmounts[_phase];
    }

}