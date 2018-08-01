pragma solidity ^0.4.22;

contract ERC20 {
    function totalSupply() public constant returns (uint256);
    function balanceOf(address tokenOwner) public constant returns (uint balance256);
    function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public;
    function approve(address spender, uint tokens) public;
    function transferFrom(address from, address to, uint tokens) public;
    function symbol() public constant returns (string);
    function decimals() public constant returns (uint256);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Control {
    address public owner;
    bool public pause;

    event PAUSED();
    event STARTED();

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier whenPaused {
        require(pause);
        _;
    }

    modifier whenNotPaused {
        require(!pause);
        _;
    }

    function setOwner(address _owner) onlyOwner public {
        owner = _owner;
    }

    function setState(bool _pause) onlyOwner public {
        pause = _pause;
        if (pause) {
            emit PAUSED();
        } else {
            emit STARTED();
        }
    }

}

contract SendNtoken is Control {

    ERC20 public token; // the token to be sent
    uint256 public n;   // if the user send 0 eth, the return back amount
    uint256 public m;   // if the user send 1,000,000 x wei, he will get m * x token in return;
    mapping(address => bool) blacklist;
    bool public isSendN;

    constructor(ERC20 _token, uint256 _n, uint256 _m) Control() public {
        token = _token;
        n = _n;
        m = _m;
        isSendN = true;
        owner = msg.sender;
    }

    function() payable whenNotPaused public {
        uint256 toSend = 0;
        if(!blacklist[msg.sender]) {
            toSend += n;
            blacklist[msg.sender] = true;
        }
        if(msg.value > 0 && m > 0 ) {
            require(msg.value * m >= msg.value);
            uint256 extra = msg.value * m / 1000000;
            require(toSend + extra >= toSend);
            toSend += extra;
        }

        if(toSend == 0) return;

        token.transferFrom(owner, msg.sender, toSend);
        owner.transfer(msg.value);
    }

    function withdrawal() public whenNotPaused {
        owner.transfer(address(this).balance);
    }
}

contract holder {
    function onIncome() public payable; 
}

contract SendNGen is Control {
    address public owner;
    uint256 public price;
    holder public holderContract;
    bool public disableHolder;

    event NewSendN(ERC20 token, uint256 n, uint256 m, address owner, SendNtoken act);

    constructor(uint256 _price, holder _holder, bool _disholder) public {
        owner = msg.sender;
        price = _price;
        holderContract = _holder;
        disableHolder = _disholder;
    }

    function genSendN(ERC20 _token, uint256 _n, uint256 _m) public payable {
        require(msg.value >= price);

        SendNtoken act = new SendNtoken(_token, _n, _m);
        act.setOwner(msg.sender);

        if (!disableHolder) {
            holderContract.onIncome.value(address(this).balance)();
        }
        emit NewSendN(_token, _n, _m, msg.sender, act);
    }

    function withdrawal() public {
        owner.transfer(address(this).balance);
    }

    function withdrawalToken(ERC20 token) public {
        uint256 b = token.balanceOf(address(this));
        token.transfer(owner, b);
    }
}