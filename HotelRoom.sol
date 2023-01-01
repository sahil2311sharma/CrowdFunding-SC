// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract HotelRoom{
    enum Statuses { Vacant, Occupied }
    Statuses public currentStatuses;

    address payable public owner;

    event occupy(address _occupant, uint _value);

    constructor(){
        owner = payable(msg.sender);
        currentStatuses = Statuses.Vacant;
    }

    modifier onlyWhileOccupancy{
        require(currentStatuses == Statuses.Vacant, "Currently Occupied");
        _;
    }
    modifier costs(uint _price) {
        require(msg.value >= _price , "Not Enough Ether Provided!!");
        _;
    }

    function book() public payable onlyWhileOccupancy costs( 2 ether){
        
        currentStatuses = Statuses.Occupied;
        // owner.payable(msg.value);

        (bool sent, bytes memory data) = owner.call{value: msg.value}("");
        require(true);
        
        emit occupy(msg.sender, msg.value);
    }
}
