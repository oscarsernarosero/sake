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
    
    address[] public lenders;
    CreditToken constant public creditToken = CreditToken(0xfFee743BD4794361Cb2EC0c86d22fb5Ac4a1568b);
    
    uint public immutable maxSize;
    mapping( address => uint ) public balances;
    mapping(address => Loan) public loansOfBorrower;
    
    //mapping (address => uint) pendingWithdrawals;
    
    constructor(uint _maxSize){
        
        maxSize = _maxSize;
        
        isOwned();
    }
    
    
    receive() external payable{
        
        require(address(this).balance + msg.value <= maxSize, "This pool is full");
        balances[msg.sender] += msg.value;
        lenders.push(msg.sender);
        
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
        payable(owner).transfer(address(this).balance);
        
        uint64 i=0;
        for (i; i<lenders.length; i++) {
            balances[lenders[i]] = 0; 
            }
        return true;
    }
    
    function createLoan( uint _collateralRequired,address payable _borrower,
                        uint _creditTokensRequired, uint _loanAmount ) public returns (address) {
                            
        //For documentation: https://github.com/ethereum/solidity/blob/develop/Changelog.md#062-2020-01-27
         Loan newLoan = new Loan{value: _loanAmount}(
                                 _collateralRequired,
                                 _borrower,
                                 _creditTokensRequired,
                                 _loanAmount
                             );
                             
         creditToken.approve (_borrower, address(newLoan), _creditTokensRequired);
         
         loansOfBorrower[_borrower] = newLoan;
     }
    
}