pragma solidity ^0.8.0;

contract DummyLendingPool{
    function receiveFromLoan(uint, uint) external payable{}
}

contract DummyPayer{
    DummyLendingPool public immutable lendingPool;
    
    constructor(address lendingPoolAddress) payable{
        lendingPool = DummyLendingPool(lendingPoolAddress);
    }
    
    function payPool(uint fees, uint interest, uint total) public {
        lendingPool.receiveFromLoan{value: total}(fees, interest);
    }
    function getEtherBalance() public view returns (uint){
        return address(this).balance;
    }
    
    
    function transferAll(address to) public {
        payable(to).transfer(address(this).balance);
    }
    
}