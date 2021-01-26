// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6; //OpenZeppelin's COMPILER CAN'T BE 0.8.0 OR HIGHER

import "./CreditToken.sol";

/*
contract CreditToken {
    
    //transfer function
    function transferFrom(address, address, uint ) public returns (bool success) {}
    
    function balanceOf(address) public view  returns (uint balance) {}
    
    function allowance(address, address ) public view  returns (uint remaining) {}
}
*/

contract Loan {
    
    CreditToken immutable public creditToken;
    uint immutable public collateralRequired;
    uint immutable public creditTokensRequired;
    bytes32 stateOfLoan = 0; // DON'T DECLARE AN EMPTY STRING? - ROBERTO
    address payable immutable public borrower;
    uint immutable public loanAmount;

    //states
    bytes32 constant WAITING_ON_COLLATERAL = "waitingOnCollateral";
    bytes32 constant TAKING_STAKE = "takingStake";
    bytes32 constant DISBURSING_LOAN = "disbursingLoan";
    bytes32 constant ACTIVE = "active";
    bytes32 constant LATE = "late";
    bytes32 constant PAID_IN_FULL = "paidInFull";
    bytes32 constant DEFAULTED = "defaulted";
    
    modifier onlyOnState(bytes32 _state) {
        require(stateOfLoan == _state,"This method cannot be called during current state.");
        _; 
    }
    
    //https://ethereum.stackexchange.com/questions/59132/deploy-contract-with-ether
    /**
     * @notice Creates a loan contract for the address
     * calling it. (Constructor is payable to receive Ether to then be lent out at creation time)
     * @param _tokenAddress address of the creditToken's contract. (only development phase. Should be hardcoded in production time)
     * @param _collateralRequired collateral in Wei THIS WILL BE FIGURED OUT BY A ALGORITHM, RIGHT? - ROBERTO
     * @param _borrower borrower's address
     * @param _creditTokensRequired CreditTokens neccessary for stake
     * @param _loanAmount Ether, in Wei, to be lent to the borrower
     */
    constructor(
        CreditToken _tokenAddress,
        uint _collateralRequired,
        address payable _borrower,
        uint _creditTokensRequired,
        uint _loanAmount
    )
        payable
    { 
        require(msg.value == _loanAmount); 
        
        collateralRequired = _collateralRequired;
        creditToken = CreditToken(_tokenAddress);
        borrower = _borrower;
        loanAmount = _loanAmount;
        creditTokensRequired = _creditTokensRequired;
        
        stateOfLoan = WAITING_ON_COLLATERAL;
    }
    
    /**
     * @notice Function to receive the collateral, in ETH, take stake of CreditTokens 
     * and disburse loan
     * @dev Requires collateral be above minimum stored in variabale, update state of stake,
     * takes stake from borrowing address, updates state of stake again, disburses loan
     */
    receive() external payable {
        require(msg.value >= collateralRequired * 1 wei, "Collateral provided is lower than collateral required.");
        
        stateOfLoan = TAKING_STAKE;
        getStake();
        
        stateOfLoan = DISBURSING_LOAN;
        disburseLoan();
        
        stateOfLoan = ACTIVE;
        
    }
    
    /*
    TEST WITHOUT FALLBACK FUNCTION
    fallback() external payable {
        receive();
    }
    */
        
    /*SHOULD IT BE A PUBLIC FUNCTION? - ROBERTO*/
    /**
     * @notice Loan Contract takes the stake of
     * CreditTokens from borrower address
     * @dev confirms the contract is allowed has gotten enough
     * CreditTokens from user's address
     */
    function getStake() public payable onlyOnState(TAKING_STAKE) returns (bool success) {
        uint256 allowance = creditToken.allowance(borrower, address(this));
        require(allowance >= creditTokensRequired, "Token balance too low");
        creditToken.transferFrom(borrower, address(this), creditTokensRequired);
        return true;
    }
    
    /**
     * @notice Provides CreditToken balance of the contract
     */
    function getCreditTokenBalance() public view  returns (uint balance) {
        return creditToken.balanceOf(address(this));
    }
    
    /**
     * @notice Provides Ether balance of the contract
     */
    function getEtherBalance() public view returns (uint){
        return address(this).balance;
    }
    
    /**
     * @notice Disburses the loan that was requested
     */
    function disburseLoan() private onlyOnState(DISBURSING_LOAN) returns(bool success){
        borrower.transfer(loanAmount);
        return true;
    }
    
}