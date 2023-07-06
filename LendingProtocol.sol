//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LendingProtocol {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public loans;

    event Deposit(address indexed depositor, uint256 amount);
    event Borrow(address indexed borrower, address indexed lender, uint256 amount);
    event Repay(address indexed borrower, address indexed lender, uint256 amount);

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");

        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function borrow(address lender, uint256 amount) public {
        require(amount > 0, "Borrow amount must be greater than zero");
        require(balances[lender] >= amount, "Insufficient funds to lend");

        balances[lender] -= amount;
        loans[msg.sender][lender] += amount;
        emit Borrow(msg.sender, lender, amount);
    }

    function repay(address borrower, uint256 amount) public {
        require(amount > 0, "Repay amount must be greater than zero");
        require(loans[borrower][msg.sender] >= amount, "Insufficient loan balance");

        loans[borrower][msg.sender] -= amount;
        balances[msg.sender] += amount;
        emit Repay(borrower, msg.sender, amount);
    }

    function checkLoanBalance(address borrower, address lender) public view returns (uint256) {
        return loans[borrower][lender];
    }

    // Additional Functions

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    // Security Features

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }