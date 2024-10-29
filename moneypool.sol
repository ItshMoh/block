// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MoneyPool {
    address public owner;
    uint public poolEndTime;
    uint public poolBalance;
    mapping(address => uint) public contributionsNumber;
    mapping(address => uint) public contributionsColor;
    mapping(address => uint) public contributionsEvenOdd;

    mapping(address => uint) public choiceNumber;
    mapping(address => uint) public choiceColor;
    mapping(address => uint) public choiceEvenOdd;

    enum BetType { Number, Color, EvenOdd }
    struct Bet {
        address player;
        BetType betType;
        uint choice; // can represent number, color, or even/odd choice
        uint amount;
    }
    address[] internal contributorsNumber;
    address[] internal contributorsColor;
    address[] internal contributorsEvenOdd;

    Bet[] internal bets;
    mapping(address => bool) public hasBet;

    event PoolOpened(uint endTime);
    event ContributionReceived(address indexed player, uint amount);
    event BetPlaced(address indexed player, BetType betType, uint choice, uint amount);
    event Payout(address indexed winner, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier poolOpen() {
        require(block.timestamp < poolEndTime, "Pool is closed for new contributions");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function openPool(uint duration) external onlyOwner {
        poolEndTime = block.timestamp + duration;
        emit PoolOpened(poolEndTime);
    }

    function placeBet(BetType betType, uint8 choice,uint8 amount) public  payable poolOpen {
        require(amount > 0, "Bet amount must be more than 0");
        require(!hasBet[msg.sender], "Player has already placed a bet");
        // Store the bet information
        bets.push(Bet({
            player: msg.sender,
            betType: betType,
            choice: choice,
            amount: amount
        }));

        // Update pool and contributions
        if(betType== BetType.Number){
          contributionsNumber[msg.sender] += amount;
          choiceNumber[msg.sender] = choice;
          contributorsNumber.push(msg.sender);
        }
        else if(betType== BetType.Color){
            contributionsColor[msg.sender] += amount;
            choiceColor[msg.sender] = choice;
            contributorsColor.push(msg.sender);
        }
        else if(betType== BetType.EvenOdd){
            contributionsEvenOdd[msg.sender] += amount; 
            choiceEvenOdd[msg.sender] = choice;
            contributorsEvenOdd.push(msg.sender);
        }

        poolBalance += amount;
        hasBet[msg.sender] = true;
        emit BetPlaced(msg.sender, betType, choice, amount);
    }

    function payout(address winner, uint amount) external onlyOwner {
        require(amount <= poolBalance, "Insufficient funds in the pool");
        payable(winner).transfer(amount);
        poolBalance -= amount;
        emit Payout(winner, amount);
    }
}

