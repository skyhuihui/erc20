pragma solidity ^0.4.23;

contract ERC20 {
    function totalSupply() public constant returns (uint256);
    function balanceOf(address tokenOwner) public constant returns (uint balance256);
    function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public;
    function approve(address spender, uint tokens) public;
    function transferFrom(address from, address to, uint tokens) public;
    function symbol() public constant returns (string);
    function decimals() public constant returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Airdrop{
    
  ERC20 token;

  event TokenTransferred(address indexed to, uint256 amount);

  function deliverTokens(ERC20 _token, address[] receivers, uint256 amount) external {
    token = _token;
    for (uint256 i = 0; i < receivers.length; i++) {
      _deliverTokens(receivers[i], amount);
    }
  }

  function deliverTokens(ERC20 _token, address[] receivers, uint256[] amount) external  {
    token = _token;
    for (uint256 i = 0; i < receivers.length; i++) {
      _deliverTokens(receivers[i], amount[i]);
    }
  }

  function _deliverTokens(address receiver, uint256 amount) internal {
    if ((receiver != address(0)) && (amount != 0) && (amount <= token.balanceOf(msg.sender))) {
      token.transferFrom(msg.sender, receiver, amount);
      emit TokenTransferred(receiver, amount);
    } 
  }

}