pragma solidity ^0.4.16;
/*
	ERC20 Token Standart
	https://github.com/ethereum/EIPs/issues/20
	https://theethereum.wiki/w/index.php/ERC20_Token_Standard
*/


contract ERC20 {


    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function totalSupply() external constant returns (uint);

    function balanceOf(address _owner) external constant returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender) external constant returns (uint256);

}
