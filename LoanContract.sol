pragma solidity ^0.8.0;

contract CreditToken {
    
    //transfer function
    function transferFrom(address, address, uint ) public returns (bool success) {}
    
    function balanceOf(address) public view  returns (uint balance) {}
    
    function allowance(address, address ) public view  returns (uint remaining) {}
}

contract Loan {
    
    CreditToken immutable public creditToken;
    uint immutable public collateralRequired;
    uint immutable public creditTokensRequired;
    uint8 state = 0;
    address payable immutable  public borrower;
    uint immutable public loanAmount;
    
    constructor ( CreditToken tokenAddr, uint _collateralRequired, address payable _borrower,
    uint _creditTokensRequired, uint _loanAmount){
        
        collateralRequired = _collateralRequired;
        creditToken = CreditToken(tokenAddr);
        borrower = _borrower;
        loanAmount = _loanAmount;
        creditTokensRequired = _creditTokensRequired;
        
    }
    
    //After this contract has been created, the borrower must put up the collateral by sending ETH
    //to the address of the Loan Contract which will be handled by this method and initiate the 
    //disbursment of the loan.
    receive() external payable{
        require(msg.value >= collateralRequired * 1 wei, "Your collateral is not enough for this loan.");
        
        //..Now that the borrower has put the ETH as collateral, we take the tokens for the loan.
        getStake();
        
        //and disburse the loan
        
    }
    
    fallback() external payable {
        require(msg.value >= collateralRequired * 1 wei, "Your collateral is not enough for this loan.");
        
        //..Now that the borrower has put the ETH as collateral, we take the tokens for the loan.
        getStake();
        
        //and disburse the loan
    }
        
    
    function getStake() public payable returns (bool success){
        
        uint256 allowance = creditToken.allowance(borrower, address(this));
        require(allowance >= creditTokensRequired, "Check the token allowance");
        creditToken.transferFrom(borrower, address(this), creditTokensRequired);
        //borrower.transfer(amount);
        
        return true;
    }
    
    function getCreditTokenBalance() public view  returns (uint balance) {
        return creditToken.balanceOf(address(this));
    }
    
    function getEtherBalance() public view returns (uint){
        return address(this).balance;
    }
    
}