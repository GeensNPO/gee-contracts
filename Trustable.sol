pragma solidity ^0.4.16;

import "./Ownable.sol";

/*
	Trustable saves trusted addresses
*/
contract Trustable is Ownable {

    //Only trusted addresses are able to transfer tokens during the Crowdsale
    mapping (address => bool) trusted;

    event AddTrusted (address indexed _trustable);
    event RemoveTrusted (address indexed _trustable);

    function Trustable() {
        trusted[msg.sender] = true;
        AddTrusted(msg.sender);
    }

    //Add new trusted address
    function addTrusted(address _address)
        external
        onlyOwner
        notZeroAddress(_address)
    {
        trusted[_address] = true;
        AddTrusted(_address);
    }

    //Remove address from a trusted list
    function removeTrusted(address _address)
        external
        onlyOwner
        notZeroAddress(_address)
    {
        trusted[_address] = false;
        RemoveTrusted(_address);
    }

}