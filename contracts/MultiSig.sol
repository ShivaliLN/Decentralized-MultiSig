// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

contract MultiSig {
    address[] public owners;
    uint public transactionCount;
    uint public required;
    uint public daysToExpire;

    event Confirmation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);

    struct Transaction {
        address payable destination;
        uint value;
        bool executed;
        bytes data;
        uint dateCreated;
        bool expired;
    }

    mapping(uint => Transaction) public transactions;
    mapping(uint => mapping(address => bool)) public confirmations;

    receive() payable external {
        emit Deposit(msg.sender, msg.value);
    }

    function getOwners() view public returns(address[] memory) {
        return owners;
    }

    function getTransactionIds(bool pending, bool executed) view public returns(uint[] memory) {
        uint count = getTransactionCount(pending, executed);
        uint[] memory txIds = new uint[](count);
        uint runningCount = 0;
        for(uint i = 0; i < transactionCount; i++) {
            if(pending && !transactions[i].executed ||
                executed && transactions[i].executed) {
                txIds[runningCount] = i;
                runningCount++;
            }
        }
        return txIds;
    }

    function getTransactionCount(bool pending, bool executed) view public returns(uint) {
        uint count = 0;
        for(uint i = 0; i < transactionCount; i++) {
            if(pending && !transactions[i].executed ||
                executed && transactions[i].executed) {
                count++;
            }
        }
        return count;
    }

    function executeTransaction(uint transactionId) public {
        require(isConfirmed(transactionId));
        emit Execution(transactionId);
        Transaction storage _tx = transactions[transactionId];
        (bool success, ) = _tx.destination.call{ value: _tx.value }(_tx.data);
        require(success, "Failed to execute transaction");
        _tx.executed = true;
    }

    function isConfirmed(uint transactionId) public view returns(bool) {
        return getConfirmationsCount(transactionId) >= required;
    }

    function getConfirmationsCount(uint transactionId) public view returns(uint) {
        uint count;
        for(uint i = 0; i < owners.length; i++) {
            if(confirmations[transactionId][owners[i]]) {
                count++;
            }
        }
        return count;
    }

    function getConfirmations(uint transactionId) public returns(address[] memory) {
        address[] memory confirmed = new address[](getConfirmationsCount(transactionId));
        uint runningConfirmed;
        for(uint i = 0; i < owners.length; i++) {
            if(confirmations[transactionId][owners[i]]) {
                confirmed[runningConfirmed] = owners[i];
                runningConfirmed++;
            }
        }
        
        if(!isConfirmed(transactionId)){
            bool successEx = checkifexpired(transactionId);
        }        
        return confirmed;
    }

    function isOwner(address addr) private view returns(bool) {
        for(uint i = 0; i < owners.length; i++) {
            if(owners[i] == addr) {
                return true;
            }
        }
        return false;
    }

    function submitTransaction(address payable dest, uint value, bytes memory data) public {
        uint id = addTransaction(dest, value, data);
        confirmTransaction(id);
        emit Submission(id);
    }

    function confirmTransaction(uint transactionId) public {
        require(isOwner(msg.sender));
        Confirmation(msg.sender, transactionId);
        confirmations[transactionId][msg.sender] = true;
        if(isConfirmed(transactionId)) {
            executeTransaction(transactionId);
        }
    }

   /*
    function expireTransaction(uint transactionId) public returns(bool) {
        //require(isOwner(msg.sender));
        Transaction storage _tx = transactions[transactionId];
        uint startDate = _tx.dateCreated; // 2018-01-01 00:00:00
        uint endDate = block.timestamp; // 2018-02-10 00:00:00
        uint diff = (endDate - startDate) / 60 / 60 / 24; // 40 days 
        if(diff>=daysToExpire){
            _tx.expired = true;
        } 
        return true;                     
    }
 */   
    function checkifexpired(uint tranId) public returns(bool){
        Transaction storage _tx = transactions[tranId];
        uint startDate = _tx.dateCreated; // 2018-01-01 00:00:00
        //uint endDate = block.timestamp; // 2018-02-10 00:00:00
        //uint diff = (endDate - startDate) / 60 / 60 / 24; // 40 days 
        if(block.timestamp > startDate + daysToExpire * 1 days){
          _tx.expired = true;
            return true;
        }
     return false;
    }

    function addTransaction(address payable destination, uint value, bytes memory data) public returns(uint) {
        transactions[transactionCount] = Transaction(destination, value, false, data, block.timestamp, false);
        transactionCount += 1;
        return transactionCount - 1;
    }

    constructor(address[] memory _owners, uint _confirmations) {
        require(_owners.length > 0);
        require(_confirmations > 0);
        require(_confirmations <= _owners.length);
        owners = _owners;
        required = _confirmations;
        daysToExpire = 10;
    }
}
