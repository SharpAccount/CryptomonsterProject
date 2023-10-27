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

    Phases phase;


    mapping(address => User) private registeredUsers;

    mapping(string => address) private logsAddresses;
    mapping(string => bytes32) private logsPasses;

    mapping(address => Whitelist) private whitelistRequires;
    mapping(address => Whitelist) private approvedRequires;


    modifier onlyThisRole(Roles _role) {
        require(_role == registeredUsers[msg.sender].role, unicode"У вас нет прав, чтоб сделать это!");
        _;
    }

    modifier onlyInThisPhase(Phases _phase) {
        require(phase == _phase, unicode"Эта фаза не началась, либо уже закончилась!");
        _;
    }


    constructor() {  
        _mint(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 10_000_000 * 10 ** decimals());


        registeredUsers[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = User("owner", 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, true, 1_000_000 * 10 ** decimals(), 3_000_000 * 10 ** decimals(), 6_000_000 * 10 ** decimals(), Roles.Owner);
        logsPasses["owner"] = keccak256(abi.encode("123"));
        logsAddresses["owner"] = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

        registeredUsers[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = User("priv prov", 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, true, 0, 0, 0, Roles.PrivateProvider);
        logsPasses["priv prov"] = keccak256(abi.encode("123"));
        logsAddresses["priv prov"] = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

        registeredUsers[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = User("pub prov", 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, true, 0, 0, 0, Roles.PublicProvider);
        logsPasses["pub prov"] = keccak256(abi.encode("123"));
        logsAddresses["pub prov"] = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;

        registeredUsers[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = User("inv1", 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, true, 300_000 * 10 ** decimals(), 0, 0, Roles.User);//300_000 * 10**decimals()
        logsPasses[string("inv1")] = keccak256(abi.encode("123"));
        logsAddresses[string("inv1")] = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;

        registeredUsers[0x617F2E2fD72FD9D5503197092aC168c91465E7f2] = User("inv2", 0x617F2E2fD72FD9D5503197092aC168c91465E7f2, true, 400_000 * 10 ** decimals(), 0, 0, Roles.User);//400_000 * 10**decimals()
        logsPasses["inv2"] = keccak256(abi.encode("123"));
        logsAddresses["inv2"] = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2;

        registeredUsers[0x17F6AD8Ef982297579C203069C1DbfFE4348c372] = User("friend", 0x17F6AD8Ef982297579C203069C1DbfFE4348c372, true, 200_000 * 10 ** decimals(), 0, 0, Roles.User);//200_000 * 10**decimals()
        logsPasses["friend"] = keccak256(abi.encode("123"));
        logsAddresses["friend"] = 0x17F6AD8Ef982297579C203069C1DbfFE4348c372;


        _resetTime();

        _transfer(logsAddresses["owner"], logsAddresses["inv1"], (300_000 * 10 ** decimals()));
        _transfer(logsAddresses["owner"], logsAddresses["inv2"], (400_000 * 10 ** decimals()));
        _transfer(logsAddresses["owner"], logsAddresses["friend"], (200_000 * 10 ** decimals()));
    }


    function signUp(string memory login, string memory password) public {
        require(logsAddresses[login] == address(0), unicode"Этот логин занят!");
        require(registeredUsers[logsAddresses[login]].wallet == address(0));

        logsAddresses[login] = msg.sender;
        logsPasses[login] = keccak256(abi.encode(password));
        registeredUsers[logsAddresses[login]] = User(login, msg.sender, false, 0, 0, 0, Roles.User);

        _resetTime();
    }

    function checkSystemLifeTime() public {
        uint256 timeLife = _resetTime();
        console.log(timeLife);
        _resetTime();
    }

    function addMinute() public {
        timeDif += 60;
        _resetTime();
    }

    function askForWhitelistInvite() public onlyInThisPhase(Phases.Seed) {
        whitelistRequires[msg.sender] = Whitelist(registeredUsers[msg.sender].login, msg.sender, false);
    }

    function acceptInviteRequests(string memory requesterLog, bool isAccepted) public onlyInThisPhase(Phases.Seed) onlyThisRole(Roles.PrivateProvider) {
        require(logsAddresses[requesterLog] != address(0), unicode"Пользователь не нашелся!");

        if (isAccepted == true) {

            registeredUsers[logsAddresses[requesterLog]].isInWhitelist = true;
            approvedRequires[logsAddresses[requesterLog]] = Whitelist(requesterLog, logsAddresses[requesterLog], true);

            delete whitelistRequires[logsAddresses[requesterLog]];

        } else {
            delete registeredUsers[logsAddresses[requesterLog]];
        }

        _resetTime();
    }

    function giveReward(address _to, uint8 amount) public onlyThisRole(Roles.PublicProvider) {
        require(registeredUsers[msg.sender].publicBalance >= amount, unicode"У вас недостаточно токенов!");
        transfer(msg.sender, _to, amount * 10**decimals(), 2);

        _resetTime();
    }

    function changeTokenCost(uint8 costWeiValue) public onlyThisRole(Roles.PublicProvider) onlyInThisPhase(Phases.Public) {
        currentPrice = costWeiValue;

        _resetTime();
    }

    function buyToken(uint256 amount) public payable {
        require(phase != Phases.Seed, unicode"Нельзя покупать токены в эту фазу!");
        require(amount <= currentMaxAmount, unicode"Нельзя переводить больше, чем органиченно данной фазой!");
        require(currentPrice * amount <= msg.value, unicode"У вас недостаточно eth!");

        if (phase == Phases.Private) {
            require(registeredUsers[msg.sender].isInWhitelist == true, unicode"Свободная продажа ещё не началась!");
            transfer(logsAddresses["priv prov"], msg.sender, amount * 10**decimals(), 1);
        } else {            
            transfer(logsAddresses["pub prov"], msg.sender, amount * 10**decimals(), 2);
        }

        _resetTime();
    }

    function signIn(string memory login, string memory password) public returns(User memory) {
        require(logsPasses[login] == keccak256(abi.encode(password)), unicode"Неверный логин или пароль!");
        _resetTime();
        return registeredUsers[logsAddresses[login]];
    }

    function decimals() public view virtual override returns (uint8) {
        return 12;
    }

    function transfer(address from, address to, uint256 amount, uint8 tokenType) private {
        require(to != address(0), unicode"Нельзя перевести токены на несуществующий адрес!");
        require(tokenType <= 2, unicode"Нельзя переводить такой тип токенов!");

        if (tokenType == 0) {
            //require(phase == Phases.Seed, unicode"Нельзя покупать seed токены в эту фазу!");

            registeredUsers[from].seedBalance -= amount;
            registeredUsers[to].seedBalance += amount;

            return;

        } else if (tokenType == 1) {
            //require(phase == Phases.Private, unicode"Нельзя покупать private токены в эту фазу!");

            registeredUsers[from].privateBalance -= amount;
            registeredUsers[to].privateBalance += amount;

        } else {
            //require(phase == Phases.Public, unicode"Нельзя покупать public токены в эту фазу!");

            registeredUsers[from].publicBalance -= amount;
            registeredUsers[to].publicBalance += amount;
        }

        _transfer(from, to, amount);
        _resetTime();
    }

    function _resetTime() private returns(uint256) {
        timeSystem = block.timestamp + timeDif;
        uint256 timeLife = (timeSystem - timeStart);

        if (((timeLife > 300) && (timeLife < 900)) && (phase != Phases.Private)) {
            phase = Phases.Private; 
            _makePhaseConditions();
        } else if ((timeLife > 900) && (phase != Phases.Public)) {
            phase = Phases.Public;
            _makePhaseConditions();
        }

        return timeLife;
    }

    function _makePhaseConditions() private {
        if (phase == Phases.Private) {
            currentPrice = 0.00075 ether;
            currentMaxAmount = 100_000 * 10 ** decimals();

            registeredUsers[logsAddresses["owner"]].privateBalance -= 3_000_000 * 10 ** decimals();
            registeredUsers[logsAddresses["priv prov"]].privateBalance += 3_000_000 * 10 ** decimals();
            _transfer(logsAddresses["owner"], logsAddresses["priv prov"], (3_000_000 * 10 ** decimals()));

        } else if (phase == Phases.Public) {
            currentPrice = 0.001 ether;
            currentMaxAmount = 5_000 * 10 ** decimals();

            uint256 tokensToReturn = registeredUsers[logsAddresses["priv prov"]].privateBalance;
            transfer(logsAddresses["priv prov"], logsAddresses["owner"], tokensToReturn, 1);

            registeredUsers[logsAddresses["owner"]].publicBalance -= 6_000_000 * 10 ** decimals();
            registeredUsers[logsAddresses["pub prov"]].publicBalance += 6_000_000 * 10 ** decimals();
            _transfer(logsAddresses["owner"], logsAddresses["pub prov"], (6_000_000 * 10 ** decimals()) );
        }
    }
}