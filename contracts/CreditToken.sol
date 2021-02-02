// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "Loan.sol";

//safemath?

contract Owned {
    
    address public owner;

    function isOwned() internal {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract LendingPool is Owned {
    
    address[] private lenders;
    CreditToken constant public creditToken = CreditToken(0x80cDF946c1c86B7eee50743E2bc9a6d7d9ed597A);
    
    uint public immutable maxSize;
    mapping( address => uint ) public balances;
    mapping(address => address[]) public loansOfBorrower;
    mapping(address => uint) public paidByLoan;
    //mapping (address => uint) pendingWithdrawals;
    
    constructor(uint _maxSize){
        
        maxSize = _maxSize;
        
        isOwned();
    }
    
    
    receive() external payable{
        
        require(address(this).balance <= maxSize, "This pool is full");
        if (balances[msg.sender] == 0){
            lenders.push(msg.sender);
        }
        balances[msg.sender] += msg.value;
        
    }
    
    function receiveFromLoan() external payable{
        paidByLoan[msg.sender]+=msg.value;
        //update balances
         uint  boostBalanceRate = (address(this).balance*10000)/(address(this).balance-msg.value); //(100 times the percentage)
         uint64 i=0;
         for (i; i<lenders.length; i++) {
            balances[lenders[i]] = (balances[lenders[i]] * boostBalanceRate)/10000; 
            }
    }
    
    function calculateInterestsYield(address lender) public {
        
    }
    
    function liquidateLoan(address loanAddr) public {
        
    }
    
    function payLender(address lender)public {
        
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function testOnlyLiquidatePool() external onlyOwner returns (bool success){
        //payable(owner).transfer(address(this).balance);
        
        uint64 i=0;
        for (i; i<lenders.length; i++) {
            payable(lenders[i]).transfer(balances[lenders[i]]);
            balances[lenders[i]] = 0; 
            }
        return true;
    }
    
    function viewLenders() public view returns (address [] memory) {
        return lenders;
    }
    
    function createLoan( uint _collateralRequired,address payable _borrower,
                        uint _creditTokensRequired, uint _loanAmount,uint _loanTerm, // in days
                        uint _interestRate  ) public {
                            
                            
        uint priorBalance = address(this).balance;            
        //For documentation: https://github.com/ethereum/solidity/blob/develop/Changelog.md#062-2020-01-27
         Loan newLoan = new Loan{value: _loanAmount}(
                                 _collateralRequired,
                                 _borrower,
                                 _creditTokensRequired,
                                 _loanAmount,
                                 _loanTerm, // in days
                                 _interestRate 
                             );
                             
         creditToken.whitelistAddress ( address(newLoan) );
         creditToken.approve (_borrower, address(newLoan), _creditTokensRequired);
         
         loansOfBorrower[_borrower].push(address(newLoan));
         
         
         //update balances
         uint  reductionBalanceRate = (address(this).balance*10000)/priorBalance; //(100 times the percentage)
         uint64 i=0;
         for (i; i<lenders.length; i++) {
            balances[lenders[i]] = (balances[lenders[i]] * reductionBalanceRate)/10000; 
            }
     }
    
}