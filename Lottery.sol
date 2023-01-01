// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Lottery{
    address payable[] public players;
    address public manager;

    constructor(){
        manager = msg.sender;
    }
    receive() external payable{
        require(msg.sender != manager, "Manager can't participate in lottery");
        require(msg.value >=  0.000000000001 ether, "Value should be greater than 1 ether");
        players.push(payable(msg.sender));
    }
    function getBalance() public view returns(uint){
        require(msg.sender == manager, "Only Manager can view the balance");
        return address(this).balance;
    }
    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }
    function pickWinner() public {
        
        require(players.length>=10, "There should be more than 10 players");

        uint r = random();
        address payable winner;

        uint index = r%players.length;

        winner = players[index];
        
        uint managerFee = (getBalance() * 10 ) / 100;
        uint winnerPrize = (getBalance() * 90 ) / 100;
        
        winner.transfer(winnerPrize);

        payable(manager).transfer(managerFee);
        
        players = new address payable[](0);
        
    }
}
