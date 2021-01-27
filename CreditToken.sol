// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6; //OpenZeppelin's COMPILER CAN'T BE 0.8.0 OR HIGHER

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

/*
****IMPORTED IERC20 FROM OPENZEPPELIN, NO NEED TO REPEAT CODE HERE****
****(NEED TO UNDERSTAND INTENTION, AS OF RIGHT NOW, NOT REALLY WORKING)****
interface ERC20Interface {

    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address owner, address spender, uint tokens) external returns (bool success);
    function transferFrom (address from, address to, uint tokens) external returns (bool success);



    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    
}
*/


contract Owner {
    
    address owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @notice establishes owner, who then has
     * access to certain functions
     */
    function  establishOwner() internal {
        owner = msg.sender;
    }
}


/**
 * @title Whitelist contract that allows owner's to
 * either blacklist or whitelist any given address
 * @author Sake team
 */
contract Whitelist is Owner {
    
    address[] public whitelistedAddress;
    
    mapping(address => bool) lendingPoolAddress;
    
    /**
     * @notice allows addresses to be confirmed to belong
     * to list of white listed addresses
     */
    modifier onlyWhiteListed {
        require(lendingPoolAddress[msg.sender] == true,"This address is not white listed.");
        _;
    }

    /**
     * @notice owner can add provided address to list of
     * white listed addresses
     */
    function whitelistAddress (address _pool) external onlyOwner {
        lendingPoolAddress[_pool] = true;
        whitelistedAddress.push(_pool);
    }
    
    /**
     * @notice owner can add provided address to list of
     * black listed addresses
     */
    function blacklistAddress (address _pool) external onlyOwner {
        lendingPoolAddress[_pool] = false;
        whitelistedAddress.push(_pool);
    }
    
}


/**
 * @title CreditToken a token that parallels the existing credit score
 * system in place in the existing system
 * @author Sake team
 * @notice Create a token representing a user's credit score,
 * which can be used to...
 */
contract CreditToken is /*ERC20Interface, SafeMath,*/ Whitelist {
    
    // Details of CT token
    string public name;
    string public symbol;
    uint8 public decimals;
    
    address[] whiteList;
    
    uint256 public totalSupply;
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed; // NEED THIS VARIABLE EXPLAINED - ROBERTO
    
    event LogCoinsMinted(address deliveredTo, uint amount);
    event LogCoinsBurned(address burnedFrom, uint amount);
    
    /**
     * @notice Creates CreditToken (CT) upon deployment with a 
     * total supply of zero.
     */
    constructor() {
        
        establishOwner();
        
        name = "CreditToken";
        symbol = "CT";
        decimals = 3;
        totalSupply = 0;

        // Sets the balance of the address that deployed
        // the contract at zero.
        balances[msg.sender] = totalSupply;
        // emit IERC20.Transfer(address(0), msg.sender, _totalSupply); REVISIT LATER
    }
    
    /**
     * @notice mints new CT to owner by a white listed address
     * @dev increases _owner's balance and _totalSupply by _amount
     */
    function mint(address _owner, uint _amount) external onlyWhiteListed { // ONLYWHITELISTED MODIFIER ALLOWS ANY WHITE LISTED ADDRESS TO MINT?
        balances[_owner] = SafeMath.add(balances[_owner], _amount);
        totalSupply = SafeMath.add(totalSupply, _amount);
        emit LogCoinsMinted(owner, _amount);
    }
    
    /**
     * @notice decreases owner's amount of CT by provided amount
     * @dev subtracts _owner's balance of CT by _amount before
     * subtracting _amount from the totalSupply
     */
    function burn(address _owner, uint _amount) external onlyWhiteListed { // ONLYWHITELISTED MODIFIER ALLOWS ANY WHITE LISTED ADDRESS TO BURN?
        balances[_owner] = SafeMath.sub(balances[_owner], _amount);
        totalSupply = SafeMath.sub(totalSupply, _amount);
        emit LogCoinsBurned(_owner, _amount);
    }
    
    /**
     * @notice Approves an address to have a certain amount of tokens CONFIRM INTENTION
     * @dev msg.sender can approve an address of tokens
     * @param _spender address who msg.sender approves
     * @param _tokens amount of tokens _spender is approved for
     */
    function approve(address _owner, address _spender, uint _tokens) public /*override*/ {
        // emit Approval(_owner, _spender, _tokens);
        allowed[_owner][_spender] = _tokens;
    }
    
    /**
     * @notice allows user to transfer tokens fromt their address to provided recipient
     * @dev subtracts tokens from sender before adding tokens to balance of recipient
     */
    function transfer(address _to, uint _tokens) public onlyWhiteListed returns (bool success) {
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _tokens);
        balances[_to] = SafeMath.add(balances[_to], _tokens);
        // emit IERC20.Transfer(msg.sender, to, tokens);
        return true;
    }
    
    /**
     * @notice allows user to transfer tokens on behalf(?) of owner to provided recipient
     * @dev subtracts tokens from sender address before adding tokens to balance of recipient
     */
    function transferFrom(address _from, address _to, uint _tokens) public returns (bool success) {
        require(_tokens <= balances[_from], "Balance too low for this transaction");
        balances[_from] = SafeMath.sub(balances[_from], _tokens);
        // OTHER CONTRACT IS CALLING THIS FUNCTION WITH ITS OWN ADDRESS AS A PARAMETER
        // IS IT NECESSARY TO CALL THIS MSG.SENDER LINE?
        // allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _tokens); NEED THIS LINE EXPLAINED - ROBERTO
        balances[_to] = SafeMath.add(balances[_to], _tokens);
        // emit IERC20.Transfer(from, to, tokens);
        return true;
    }
    
    /**
     * @notice displays all addresses that have been whitelisted
     * @dev returns all stored data in whitelistedAddress array
     */
    function viewWhitelist() public returns (address[] memory) {
        whiteList = whitelistedAddress;
        return  whiteList;
    }
    
    /**
     * @notice returns balance of the total supply
     * of CT.
     * @dev getter function that returns value of
     * _totalSupply variable.
     */
    function getTotalSupply() public view returns (uint) {
        return totalSupply - balances[address(0)]; // WHY SUBTRACT FROM _TOTALSUPPLY
    }
    
    /**
     * @notice returns credit score of address calling
     * the function.
     * @dev returns the balance of CT from msg.sender'sender
     * address
     */
    function checkScore() public view returns (uint score) {
        score = balances[msg.sender];
        return score;
    }
    
    /**
     * @notice Get balance of CT from the provided address
     * @dev returns balance of CT from balances mapping from
     * param address
     */
    function balanceOf(address _tokenOwner) public view /*override*/ returns (uint balance) {
        return balances[_tokenOwner];
    }
    
    /**
     * @notice provides address of spender of a particular token CONFIRM INTENTION
     * @dev returns uint from mapping of _spender, which was returned from mapping of _tokenOwner
     * @param _tokenOwner owner of token CONFIRM INTENTION
     * @param _spender address of who is allowed to spend on behalf of _tokenOwner
     */
    function allowance(address _tokenOwner, address _spender) public view /*override*/ returns (uint remaining) {
        return allowed[_tokenOwner][_spender];
    }
    
}