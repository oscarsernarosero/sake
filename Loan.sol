pragma solidity ^0.8.0;

contract CreditToken {
    
    //transfer function
    function transferFrom(address, address, uint ) public returns (bool ) {}
    function balanceOf(address) public view  returns (uint ) {}
    function allowance(address, address ) public view  returns (uint ) {}
    function transfer(address , uint ) external returns (bool ){}
    function whitelistAddress (address ) external {}
    function approve(address owner, address spender, uint tokens) external returns (bool success){}
}


contract Loan{
    
    CreditToken constant public creditToken = CreditToken(0x0Af46820AEB180757A473B443B02fc511f4feffe);
    address immutable public lendingPool;
    uint immutable public collateralRequired;
    uint immutable public creditTokensRequired;
    uint immutable public creationTime;
    address payable immutable  public borrower;
    uint immutable public loanAmount;
    uint immutable public loanTerm;
    uint public lastPayment;
    int public principal = 0;
    uint public paidBack = 0;
    uint immutable public interestRate;
    uint public interestsPaid = 0;
    uint public spamFee = 150;
    uint public paidFees = 0;
    
    
    enum States {
        WaitingOnCollateral,
        TakingStake,
        DisbursingLoan,
        Active,
        Late,
        PaidInFull,
        Defaulted
    }
    
    States public state;
    
    //https://ethereum.stackexchange.com/questions/59132/deploy-contract-with-ether
    constructor ( 
        //CreditToken tokenAddr, //the address of the credittoken's contract. (only development phase. Should be hardcoded in production time)
        uint _collateralRequired, //the Ether amount of the collateral in weis
        address payable _borrower, //address of the borroweaddress
        uint _creditTokensRequired, // the Credit Tokens neccessary to put up as stake
        uint _loanAmount, //The amount of Ether that is going to be lended to the borrower (weis)
        uint _loanTerm, // in days
        uint _interestRate // in percentual points muliplied by 100 (i.e. 1.5% = 150)
        )
        payable{ // The constructor is payable because it will receive the Ether to be lended at creation time
        
        require(msg.value == _loanAmount); 
        
        creationTime = block.timestamp;
        lendingPool = msg.sender;
        lastPayment = block.timestamp;
        collateralRequired = _collateralRequired;
        loanTerm = _loanTerm;
        borrower = _borrower;
        loanAmount = _loanAmount;
        creditTokensRequired = _creditTokensRequired;
        interestRate = _interestRate;
        
        state = States.WaitingOnCollateral;
    }
    
    
    modifier onlyOnState(States _state) {
        require(state == _state,"Function cannot be called at this time.");
        _;
    }

    function nextState() internal {
        state = States(uint(state) + 1);
    }
    
    //After this contract has been created, the borrower must put up the collateral by sending ETH
    //to the address of the Loan Contract which will be handled by this method and initiate the 
    //disbursement of the loan.
    receive() external payable{
        
        if (state == States.WaitingOnCollateral){
            takeCollateralDisburseLoan();
        }
        else if(state == States.Active){
            receivePayment();
        }
    }
    
    function takeCollateralDisburseLoan() internal{
        
        uint thisSpamFee = (loanAmount * spamFee)/10000;
        require(msg.value >= (collateralRequired + thisSpamFee) * 1 wei, "Your collateral is not enough for this loan.");
        
        paidFees += thisSpamFee;
        uint collateralSent = msg.value - thisSpamFee;
        
        //..Now that the borrower has put the ETH as collateral, we take the CreditTokens for the loan.
        nextState();
        getStake();
        
        //and disburse the loan
        nextState();
        disburseLoan();
        
        principal = int(loanAmount);
        //Taking care of excesive Ether sent: //ALSO, TAKE CARE OF ATTACK WHERE THE EXCESIVE ETHER WOULD BE ENOUH TO PAYOFF THE DEBT
        if(collateralSent > collateralRequired){
            principal -= int(collateralSent - collateralRequired);
            paidBack += (collateralSent - collateralRequired);
        }
        
        nextState();
    }
    
    function receivePayment() internal{
        // the payment has to be able to cover at least the interests borrowed
            uint interests = calculateInteresestsofPayment();
            require( msg.value >= interests, "Your payment has to cover at least the interests owed today." );
            interestsPaid += interests;
            uint toPrincipal = msg.value - interests;
            principal -= int(toPrincipal);
            paidBack += toPrincipal;
            
            if(principal<=0){
                closeLoan();
            }
            lastPayment = block.timestamp;
    }
    
    function closeLoan()internal onlyOnState(States.Active){
        payPool();
        returnAllCreditTokens();
        returnCollateral();
        state = States.PaidInFull;
    }
        
    function getStake() public payable onlyOnState( States.TakingStake) returns (bool success){
        
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
    
    function disburseLoan() private onlyOnState( States.DisbursingLoan ) returns(bool success){
        borrower.transfer(loanAmount);
        principal = int(loanAmount);
        return true;
    }
    
    function returnCollateral() public returns(bool success){ //SET TO PRIVATE!!!
        //borrower.transfer(collateralRequired);
        borrower.transfer(address(this).balance);
        return true;
    }
    
    function payPool() public returns(bool success){ //SET TO PRIVATE!!!
        payable(lendingPool).transfer(paidFees + interestsPaid + paidBack);
        return true;
    }
    
    function returnAllCreditTokens() public returns(bool success){ //SET TO PRIVATE!!!
        creditToken.transfer(borrower, creditToken.balanceOf(address(this) ) );
        return true;
    }
    
    function calculateInteresestsofPayment() public view returns(uint){
        //###### REAL CODE (IN DAYS) ######
        // uint nDays = (block.timestamp  - lastPayment)/(1 days);
        // uint interestsPct = ( 10000 + interestRate )**nDays - 10000;
        
        //###### TEST CODE (IN MINUTES) #######
        uint nDays = (block.timestamp  - lastPayment)/60;
        return interestRate*nDays*uint(principal)/10000;
    }
    
    function howMuchToPayOff() public view returns(uint){
        uint interests = calculateInteresestsofPayment();
        if (principal >= 0){
            return uint(principal) + interests;
        }else{
            return 0;
        }
        
    }
}
