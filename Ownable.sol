pragma solidity ^0.8.7;

contract Ownable {
    //the creator of the contract
    address creator;

    modifier onlyCreator() {
        require(msg.sender == creator);
        _;
    }
    constructor() {
        creator = msg.sender;
    }
}
