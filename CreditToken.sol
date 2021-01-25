pragma solidity ^0.7.4;

interface ERC20Interface {

    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom (address from, address to, uint tokens) external returns (bool success);



    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a); c = a - b; 
        
    } 
    function safeMul(uint a, uint b) internal pure returns (uint c) { 
        c = a * b; 
        require(a == 0 || c / a == b); 
    } 
    function safeDiv(uint a, uint b) internal pure returns (uint c) { 
        require(b > 0);
        c = a / b;
    }
}

contract Owned {
    
    address owner;

    function isOwned() internal {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}
contract Whitelist is Owned {
    address[] public whitelistedAddress;
    
    mapping (address => bool) userAddr;

    function whitelistAddress (address user) external onlyOwner {
        userAddr[user] = true;
        whitelistedAddress.push(user);
    }
}

contract CreditToken is ERC20Interface, SafeMath, Owned, Whitelist {
        
    string public name;
    string public symbol;
    uint public decimals;
    address [] whiteList;
    
    uint256 public _totalSupply;
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    event LogCoinsMinted(address deliveredTo, uint amount);
    event LogCoinsBurned(address burnedFrom, uint amount);
    
    
    constructor() public {
        name = "CreditToken";
        symbol = "CT";
        decimals = 18;
        _totalSupply = 1000000000000000000;
        
        isOwned();

        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

        function totalSupply() public override view returns (uint) {
            return _totalSupply - balances[address(0)];
        }
        
        function checkScore() public view returns (uint score) {
            score = balances[msg.sender];
            return score;
        }
        
        function balanceOf(address tokenOwner) public view override returns (uint balance) {
            return balances[tokenOwner];
        }
        
        function allowance(address tokenOwner, address spender) public view override returns (uint remaining) {
            return allowed[tokenOwner][spender];
        }
        
        function approve(address spender, uint tokens) public override returns (bool success) {
            allowed[msg.sender][spender] = tokens;
            emit Approval(msg.sender, spender, tokens);
            return true;
        }
        
        function transfer(address to, uint tokens) public override safeTransfer returns (bool success) {
            balances[msg.sender] = safeSub(balances[msg.sender], tokens);
            balances[to] = safeAdd(balances[to], tokens);
            emit Transfer(msg.sender, to, tokens);
            return true;
        }
        
        modifier safeTransfer {
            for(uint i; i< whitelistedAddress.length;i++){
                if(msg.sender == whitelistedAddress[i]){
                    _;
                }
            }
        }
        
        function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
            balances[from] = safeSub(balances[from], tokens);
            allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
            balances[to] = safeAdd(balances[to], tokens);
            emit Transfer(from, to, tokens);
            return true;
        }
        
        function viewWhitelist() public returns (address [] memory) {
            whiteList = whitelistedAddress;
            return  whiteList;
        }
        
        function mint(address owner, uint amount) external safeMint {
            balances[owner] += amount;
            _totalSupply += amount;
            LogCoinsMinted(owner, amount);
        }
        
        modifier safeMint {
            for(uint i; i< whitelistedAddress.length;i++){
                if(msg.sender == whitelistedAddress[i]){
                    _;
                }
            }
        }
        
        function burn(address owner, uint amount) external safeBurn {
            balances[owner] -= amount;
            _totalSupply -= amount;
            LogCoinsBurned(owner, amount);
        }
        
        modifier safeBurn {
            for(uint i; i< whitelistedAddress.length;i++){
                if(msg.sender == whitelistedAddress[i]){
                    _;
                }
            }
        }
}