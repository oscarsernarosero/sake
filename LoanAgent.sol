pragma solidity ^0.8.0;

contract CreditToken {
    
    //transfer function
    //function transferFrom(address, address, uint ) public returns (bool success) {}
    function balanceOf(address) public view  returns (uint balance) {}
    // function allowance(address, address ) public view  returns (uint remaining) {}
    // function transfer(address to, uint tokens) external returns (bool success){}
}

contract LoanAgent{
    
    address immutable public lendingPoolAddr;
    CreditToken constant public creditToken = CreditToken(0xfFee743BD4794361Cb2EC0c86d22fb5Ac4a1568b);
    
    struct Offer { 
              uint loanAmount;
              uint collateralETH;
              uint loanTerm;
              uint APR;
              uint totalInterests;
              }
    
    constructor(address _lendingPoolAddr) {
        lendingPoolAddr = _lendingPoolAddr;
    }
    
    function askForLoan(
            uint _loanTerm, //in hours
            uint _loanAmount, //in weis
            uint creditTokensToStake // in thousandths of tokens (0.001)
            ) public view returns (Offer memory) {
        //we retrieve the credit score of the potential borrower
        uint creditScore = creditToken.balanceOf(msg.sender);
        require(creditScore>=creditTokensToStake, "You don't have the credit tokens you are trying to stake");
        //we calculate the collateral necessary for this loan depending on the credit score.
        uint collateral = calculateCollateral(creditTokensToStake, _loanAmount);
        //we calculate an amortization plan depending on the loan term and the loan amount
        uint _APR = getAPR();
        uint totalInterests = calculateInterests( _loanTerm, _loanAmount, _APR);
        //we elaborate a struct with the offer
        Offer memory offer;
        offer = Offer( _loanAmount, collateral, _loanTerm, _APR, totalInterests );
        return offer;
    }
    
    function calculateCollateral(uint creditScore, uint loanAmount) private pure returns (uint collateral){
      return loanAmount/(75*creditScore/10000000);
      
    }
    
    function calculateInterests( uint loanTerm, uint loanAmount, uint _APR ) private pure returns (uint totalInterests){
        return _APR*;
    }
    
    function getAPR() private pure returns (uint APR){
        return 25;
    }
    
    
}