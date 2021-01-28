pragma solidity ^0.8.0;

contract CreditToken {
    
    //transfer function
    function transferFrom(address, address, uint ) public returns (bool success) {}
    function balanceOf(address) public view  returns (uint balance) {}
    function allowance(address, address ) public view  returns (uint remaining) {}
    function transfer(address to, uint tokens) external returns (bool success){}
}


contract Loan{
    
    CreditToken constant public creditToken = CreditToken(0xfFee743BD4794361Cb2EC0c86d22fb5Ac4a1568b);
    uint immutable public collateralRequired;
    uint immutable public creditTokensRequired;
    bytes32 public state;
    address payable immutable public borrower;
    uint immutable public loanAmount;
    
    //states
    //to read them use https://web3-type-converter.onbrn.com/
    bytes32 constant WAITING_ON_COLLATERAL = "waitingOnCollateral";
    bytes32 constant TAKING_STAKE = "takingStake";
    bytes32 constant DISBURSING_LOAN = "disbursingLoan";
    bytes32 constant ACTIVE = "active";
    bytes32 constant LATE = "late";
    bytes32 constant PAID_IN_FULL = "paidInFull";
    bytes32 constant DEFAULTED = "defaulted";
    
    //https://ethereum.stackexchange.com/questions/59132/deploy-contract-with-ether
    constructor ( 
        //CreditToken tokenAddr, //the address of the credittoken's contract. (only development phase. Should be hardcoded in production time)
        uint _collateralRequired, //the Ether amount of the collateral in weis
        address payable _borrower, //address of the borroweaddress
        uint _creditTokensRequired, // the Credit Tokens neccessary to put up as stake
        uint _loanAmount //The amount of Ether that is going to be lended to the borrower (weis)
        )
        payable{ // The constructor is payable because it will receive the Ether to be lended at creation time
        
        require(msg.value == _loanAmount); 
        
        collateralRequired = _collateralRequired;
        //creditToken = CreditToken(tokenAddr);
        borrower = _borrower;
        loanAmount = _loanAmount;
        creditTokensRequired = _creditTokensRequired;
        
        state = WAITING_ON_COLLATERAL;
    }
    
    modifier onlyOnState(bytes32 _state) {
            require(state==_state,"This method cannot be called during current state.");
            _;
    }
    
   
    function getStake(address payable borrower, uint amount) public payable returns (bool success){
        
        
        uint256 allowance = creditToken.allowance(borrower, address(this));
        require(allowance >= amount, "Check the token allowance");
        creditToken.transferFrom(borrower, address(this), amount);
        return true;
    }

    //After this contract has been created, the borrower must put up the collateral by sending ETH
    //to the address of the Loan Contract which will be handled by this method and initiate the 
    //disbursement of the loan.
    receive() external payable{
        require(msg.value >= collateralRequired * 1 wei, "Your collateral is not enough for this loan.");
        
        //TO-DO: take care of excesive Ether sent, or simply give it back at the end
        
        //..Now that the borrower has put the ETH as collateral, we take the CreditTokens for the loan.
        state = TAKING_STAKE;
        getStake();
        
        //and disburse the loan
        state = DISBURSING_LOAN;
        disburseLoan();
        
        state = ACTIVE;
        
    }

    fallback() external payable {
        
        require(msg.value >= collateralRequired * 1 wei, "Your collateral is not enough for this loan.");
        
        //..Now that the borrower has put the ETH as collateral, we take the tokens for the loan.
        state = TAKING_STAKE;
        getStake();
        
        //and disburse the loan
        state = DISBURSING_LOAN;
        disburseLoan();
        
        state = ACTIVE;
    }
        
    //the onlyOnState modifier works around the fact that payable functions cannot be internal nor private
    function getStake() public payable onlyOnState(TAKING_STAKE) returns (bool success){
        
        uint256 allowance = creditToken.allowance(borrower, address(this));
        require(allowance >= creditTokensRequired, "Check the token allowance");
        creditToken.transferFrom(borrower, address(this), creditTokensRequired);
        return true;
    }
    
    function getCreditTokenBalance() public view  returns (uint balance) {
        return creditToken.balanceOf(address(this));
    }
    
    function getEtherBalance() public view returns (uint){
        return address(this).balance;
    }
    
    function disburseLoan() onlyOnState(DISBURSING_LOAN) private returns(bool success){
        borrower.transfer(loanAmount);
        return true;
    }
    
    function returnCollateral() public returns(bool success){ //SET TO PRIVATE!!!
        borrower.transfer(address(this).balance);
        return true;
    }
    
    function returnAllCreditTokens() public returns(bool success){ //SET TO PRIVATE!!!
        creditToken.transfer(borrower, creditToken.balanceOf(address(this) ) );
        return true;
    }
}
