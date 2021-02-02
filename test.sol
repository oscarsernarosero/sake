pragma solidity ^0.8.0;


contract TestPool{
    
    struct Balance {
        uint balance;
        uint lastPayment;
        uint totalPayable;
    }
    
    uint immutable public creationTime;
    mapping( address => Balance[] ) public balances;
    address[] private lenders;
    mapping(address => uint) public paidByLoan;
    uint public earnedInterest;
    uint public earnedFees;
    
    event Log(string msg);
    event totalInterestWorthyBalanceEvent(address lender,uint balance, bool multipleBalances);
    event genericUint(string name, uint value);
    
    constructor(){
        creationTime = block.timestamp;
    }
    
    receive() external payable{
        
        if (balances[msg.sender].length == 0 ){
            emit Log("New Lender");
            lenders.push(msg.sender);
        }
        Balance memory newBalance;
        newBalance.balance = msg.value;
        newBalance.lastPayment = block.timestamp;
        balances[msg.sender].push(newBalance);
        emit Log("New lender balance");
    }
    
    function payLenders() public {
        uint totalCapital;
        
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
            totalCapital+=totalInterestWorthyBalance;
        }
        emit genericUint("totalCapital", totalCapital);
        
        uint yieldRate = ((earnedFees + earnedInterest) * 1000000)/totalCapital;
        emit genericUint("yieldRate", yieldRate);
        
        for (uint k; k<lenders.length; k++){
            uint yield = (yieldRate * balances[lenders[k]][0].totalPayable)/1000000;
            emit genericUint("yield: ", yield);
            payable(lenders[k]).transfer(yield);
            balances[lenders[k]][0].totalPayable = 0;
        }
        earnedFees=0;
        earnedInterest=0;
    }
    
    function receiveFromLoan(uint fees, uint interest) external payable{
        require(fees + interest <=msg.value);
        paidByLoan[msg.sender]+=msg.value;
        earnedFees += fees;
        earnedInterest += interest;
        
    }
    
    function getEtherBalance() public view returns (uint){
        return address(this).balance;
    }
    
    function transferAll(address to) public {
        payable(to).transfer(address(this).balance);
    }
   
} 