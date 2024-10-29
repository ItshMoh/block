// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./moneypool2.sol";
import "@oasisprotocol/sapphire-contracts/contracts/Sapphire.sol";

contract RouletteGame is MoneyPool {
    MoneyPool public poolContract;
    uint public matchEndTime;
    uint public maxFeePercent = 2;
    uint public matchFee;

    event MatchScheduled(uint endTime, uint matchFee);
    event MatchEnded(address indexed winner, uint payout);
   
    address[] internal winnerNumber;
    address[] internal winnerColor;
    address[] internal winnerEvenOdd;


    modifier matchOpen() {
        require(block.timestamp < matchEndTime, "Match is closed");
        _;
    }

    constructor(address _poolAddress) {
        poolContract = MoneyPool(_poolAddress);
        owner = msg.sender;
    }

    function scheduleMatch(uint duration, uint feePercent) external onlyOwner {
        require(feePercent <= maxFeePercent, "Fee exceeds max allowed percent");
        matchEndTime = block.timestamp + duration;
        matchFee = (poolContract.poolBalance() * feePercent) / 100;
        emit MatchScheduled(matchEndTime, matchFee);
    }

    function endMatch() external onlyOwner {
        // Call RNG oracle here to get the outcome (pseudo-code for example)
        uint winningNumber = getRandomNumber();

        // Determine winners and distribute funds
        for (uint i = 0; i < bets.length; i++) {
            Bet memory bet = bets[i];
            bool won = (bet.betType == BetType.Number && bet.choice == winningNumber)
                        || (bet.betType == BetType.Color && isColorWinner(winningNumber, bet.choice))
                        || (bet.betType == BetType.EvenOdd && isEvenOddWinner(winningNumber, bet.choice));
            
            if (won) {
                uint payout = calculatePayout(bet.amount);
                poolContract.payout(bet.player, payout);
                emit MatchEnded(bet.player, payout);
            }
        }
    }
    
    function getRandomBytes() internal view returns (uint256){
       bytes memory randomBytes = Sapphire.randomBytes(32, "");
       return uint256(keccak256(randomBytes));
    }

    function betOnNumber  (uint8 numberchosen,uint8 amount ) public{
       require((numberchosen>36),"The number must not be greater than 36");
       placeBet(MoneyPool.BetType.Number,numberchosen, amount); 
    }

    function betOnColor  (uint8 Colorchosen,uint8 amount ) public{
       placeBet(MoneyPool.BetType.Color,Colorchosen, amount); 
    }

    function betOnParity  (uint8 paritychosen,uint8 amount ) public{
       placeBet(MoneyPool.BetType.EvenOdd,paritychosen, amount); 
    }
    
    function isNumberWinner() internal view returns(){
        uint256 randomseed = getRandomBytes();
        uint8 winningNumber = uint8(randomseed % 37); 
        
        for(uint i=0;i<contributorsNumber.length;i++){
            address tocheckAddress = contributorsNumber[i]; 

            if(choiceNumber[tocheckAddress]==winningNumber){
                return tocheckAddress;
            }

        }
        
    }
    function isColorWinner(uint number, uint choice) internal pure returns (bool) {
        
    }

    function isEvenOddWinner(uint number, uint choice) internal pure returns (bool) {
        
    }

    function calculatePayout(uint betAmount) internal view returns (uint) {
        return betAmount * 2; // Simple example, adjust as needed for odds
    }

    function getRandomNumber() internal view returns (uint) {
        // Example RNG call, replace with actual RNG oracle implementation
    }
}
