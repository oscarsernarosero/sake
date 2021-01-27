pragma solidity ^0.8.0;

contract LendingPool {
    
    uint public immutable maxSize;
    
    constructor(uint _maxSize){
        maxSize = _maxSize;
    }
    
    mapping( address => uint ) balances;
    
    receive() external payable{
        
        require(address(this).balance + msg.value <= maxSize, "This pool is full");
        balances[msg.sender] += msg.value;
        
    }
    
    function calculateInterestsYield(address lender) private {
        
    }
    
    function liquidateLoan(address loanAddr) private {
        
    }
    
    function payLender(address lender)public {
        
    }
    
    
    
}