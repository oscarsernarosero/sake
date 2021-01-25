pragma solidity ^0.7.4;

contract CreditToken {
    
    //transfer function
    function transferFrom(address, address, uint ) public returns (bool success) {}
    
    function balanceOf(address) public view  returns (uint balance) {}
    
    function allowance(address, address ) public view  returns (uint remaining) {}
}

contract Loan {
    
    CreditToken public creditToken;
    
    constructor (CreditToken tokenAddr){
        creditToken = CreditToken(tokenAddr);
    }
    
    function getStake(address payable borrower, uint amount) public returns (bool success){
        
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = creditToken.allowance(borrower, address(this));
        require(allowance >= amount, "Check the token allowance");
        creditToken.transferFrom(borrower, address(this), amount);
        borrower.transfer(amount);
        
        return true;
    }
    
    function getBalance() public view  returns (uint balance) {
        return creditToken.balanceOf(address(this));
    }
}
