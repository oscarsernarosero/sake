pragma solidity ^0.8.0;


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
    
    uint public immutable maxSize;
    mapping( address => uint ) public balances;
    
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
    
}