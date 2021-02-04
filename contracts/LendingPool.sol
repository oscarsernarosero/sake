// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Loan.sol";

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
    
    struct Balance {
        uint balance;
        uint lastPayment;
        uint totalPayable;
    }
    mapping( address => Balance[] ) public balances;
    address[] private lenders;
    CreditToken constant public creditToken = CreditToken(0x80cDF946c1c86B7eee50743E2bc9a6d7d9ed597A);
    
    uint public immutable maxSize;
    mapping(address => address[]) public loansOfBorrower;
    mapping(address => uint) public paidByLoan;
    uint public periodInterest;
    uint public periodFees;
    
    event Log(string msg);
    event totalInterestWorthyBalanceEvent(address lender,uint balance, bool multipleBalances);
    event genericUint(string name, uint value);
    
    constructor(uint _maxSize){
        
        maxSize = _maxSize;
        
        isOwned();
    }
    
    
    receive() external payable{
        
        require(address(this).balance <= maxSize, "This pool is full");
        if (balances[msg.sender].length == 0 ){
            emit Log("New Lender");
            lenders.push(msg.sender);
        }
        Balance memory newBalance;
        newBalance.balance = msg.value;
        newBalance.lastPayment = block.timestamp;
        balances[msg.sender].push(newBalance);
        emit Log("added lender balance");
        
    }
    
    function receiveFromLoan(uint fees, uint interest) external payable{
        paidByLoan[msg.sender]+=msg.value;
        periodFees += fees;
        periodInterest += interest;
        
    }
    
    function liquidateLoan(address loanAddr) public {
        
    }
    
    function payLenders() public {
        uint totalInterestWorthyCapital = calculateInterestWorthyCapital();
        uint yieldRate = ((periodFees + periodInterest) * 1000000)/totalInterestWorthyCapital;
        emit genericUint("yieldRate", yieldRate);
        
        for (uint k; k<lenders.length; k++){
            uint yield = (yieldRate * balances[lenders[k]][0].totalPayable)/1000000;
            emit genericUint("yield: ", yield);
            payable(lenders[k]).transfer(yield);
            balances[lenders[k]][0].totalPayable = 0;
        }
        periodFees=0;
        periodInterest=0;
    }
    
    function calculateInterestWorthyCapital()public returns (uint){
        uint totalInterestWorthyCapital;
        
        for (uint i; i<lenders.length; i++){
            uint totalInterestWorthyBalance;
            if (balances[lenders[i]].length>1){
                uint realBalance;
                for (uint j; j<balances[lenders[i]].length;j++){
                    uint balance = balances[lenders[i]][j].balance;
                    emit genericUint("balance",balance);
                    uint nDays = (block.timestamp-balances[lenders[i]][j].lastPayment)/60;
                    emit genericUint("nDays",nDays);
                    totalInterestWorthyBalance+=balance*nDays;
                    realBalance+=balance;
                }
                //after we have paid the lenders for balances introduced on different times, we
                //proceed to unify the balances under a single date
                for (uint j=1; j<balances[lenders[i]].length;j++){
                    balances[lenders[i]].pop();
                }
                balances[lenders[i]][0].balance = realBalance;
                balances[lenders[i]][0].lastPayment = block.timestamp;
                balances[lenders[i]][0].totalPayable = totalInterestWorthyBalance;
                emit totalInterestWorthyBalanceEvent(lenders[i], totalInterestWorthyBalance, true);
            
            }else{
                uint balance = balances[lenders[i]][0].balance;
                emit genericUint("balance",balance);
                uint nDays = (block.timestamp-balances[lenders[i]][0].lastPayment)/60;
                emit genericUint("nDays",nDays);
                totalInterestWorthyBalance = balance*nDays;
                balances[lenders[i]][0].totalPayable = totalInterestWorthyBalance;
                emit totalInterestWorthyBalanceEvent(lenders[i], totalInterestWorthyBalance, false);
            }
            totalInterestWorthyCapital+=totalInterestWorthyBalance;
        }
        emit genericUint("totalCapital", totalInterestWorthyCapital);
        return totalInterestWorthyCapital;
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function transferAll(address to) public onlyOwner{
        payable(to).transfer(address(this).balance);
    }
    
    function viewLenders() public view returns (address [] memory) {
        return lenders;
    }
    
    function createLoan(
        uint _collateralRequired,
        address payable _borrower,
        uint _creditTokensRequired,
        uint _loanAmount,
        uint _loanTerm, // in days
        uint _interestRate
    )
        public
    {
        //uint priorBalance = address(this).balance;            
        //For documentation: https://github.com/ethereum/solidity/blob/develop/Changelog.md#062-2020-01-27
         Loan newLoan = new Loan{value: _loanAmount} (
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
     }
    
}