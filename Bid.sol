// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract AuctionCreator{
    Bid[] public auctions; 
    
    function createAuction() public{
        Bid newAuction = new Bid(payable(msg.sender)); 
        auctions.push(newAuction);
    }
}

contract Bid{
    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;
    
    enum State {Started, Running, Cancel, Ended}
    State public auctionState;

    uint public highestBiddingBid;
    address payable public highestBidder;

    mapping(address => uint) public bids;

    uint bidIncrement;

    bool public ownerFinalized = false;

    constructor(address payable eoa){
        owner = eoa;
        auctionState = State.Running;

        startBlock = block.number;
        endBlock = startBlock+40320;
        
        ipfsHash = "";
        bidIncrement = 100;
    }

    modifier notOwner(){
        require(msg.sender != owner);
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    modifier afterStart(){
        require(block.number >= startBlock);
        _;
    }
    
    modifier beforeEnd(){
        require(block.number <= endBlock);
        _;
    }

    function min(uint a, uint b) pure internal returns(uint){
        if (a <= b){
            return a;
        }
        return b;
    }

    function cancelAuction() public beforeEnd onlyOwner{
        auctionState = State.Cancel;
    }
    
    function placeBid() public payable notOwner afterStart beforeEnd returns(bool){
        require(auctionState == State.Running);
        require(msg.value>= 100 wei);

        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestBiddingBid);

        bids[msg.sender] = currentBid;

        if (currentBid <= bids[highestBidder]){
            highestBiddingBid = min(currentBid + bidIncrement, bids[highestBidder]);
        } else{
            highestBiddingBid = min(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }
        return true;
    }
    function finalizeAuction() public{
        require(auctionState == State.Cancel || block.number > endBlock); 
        require(msg.sender == owner || bids[msg.sender] > 0);

        address payable recieptant;
        uint value;

        if(auctionState == State.Cancel){
            recieptant = payable(msg.sender);
            value = bids[msg.sender];
        } else {
            if(msg.sender == owner && ownerFinalized == false){
                recieptant = owner;
                value = highestBiddingBid;
                ownerFinalized = true; 
            }
            else{
                if(msg.sender == highestBidder){
                    recieptant = highestBidder;
                    value = bids[highestBidder] - highestBiddingBid;
                }
                else{
                    recieptant = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }
        bids[recieptant] = 0;
        recieptant.transfer(value);
    }
}
