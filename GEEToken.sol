pragma solidity ^0.4.16;

/*
	@title GEEToken
*/

import "./MigratableToken.sol";

/*
	Contract defines specific token
*/
contract GEEToken is MigratableToken {

    
    //Name of the token
    string public constant name = "Geens Platform Token";
    //Symbol of the token
    string public constant symbol = "GEE";
    //Number of decimals of GEE
    uint8 public constant decimals = 8;

    //Team allocation
    //Team wallet that will be unlocked after ICO
    address public constant TEAM0 = 0x9B4df4ac63B6049DD013090d3F639Fd2EA5A02d3;
    //Team wallet that will be unlocked after 0.5 year after ICO
    address public constant TEAM1 = 0x4df9348239f6C1260Fc5d0611755cc1EF830Ff6c;
    //Team wallet that will be unlocked after 1 year after ICO
    address public constant TEAM2 = 0x4902A52F95d9D47531Bed079B5B028c7F89ad47b;
    //0.5 year after ICO
    uint256 public constant BLOCK_TEAM1 = 1835640;
    //1 year after ICO
    uint256 public constant BLOCK_TEAM2 = 1835650;
    //1st team wallet balance
    uint256 public team1Balance;
    //2nd team wallet balance
    uint256 public team2Balance;

    //Community allocation
    address public constant COMMUNITY = 0x265FC1d98f3C0D42e4273F542917525C3c3F925A;

    //2.4%
    uint256 private constant TEAM0_THOUSANDTH = 24;
    //3.6%
    uint256 private constant TEAM1_THOUSANDTH = 36;
    //6%
    uint256 private constant TEAM2_THOUSANDTH = 60;
    //67%
    uint256 private constant ICO_THOUSANDTH = 670;
    //21%
    uint256 private constant COMMUNITY_THOUSANDTH = 210;
    //100%
    uint256 private constant DENOMINATOR = 1000;

    function GEEToken() {
        //88% of _totalSupply
        balances[msg.sender] = _totalSupply * ICO_THOUSANDTH / DENOMINATOR;
        //2.4% of _totalSupply
        balances[TEAM0] = _totalSupply * TEAM0_THOUSANDTH / DENOMINATOR;
        //3.6% of _totalSupply
        team1Balance = _totalSupply * TEAM1_THOUSANDTH / DENOMINATOR;
        //6% of _totalSupply
        team2Balance = _totalSupply * TEAM2_THOUSANDTH / DENOMINATOR;
        //21% of _totalSupply
        balances[COMMUNITY] =  _totalSupply * COMMUNITY_THOUSANDTH / DENOMINATOR;

        Transfer (this, msg.sender, balances[msg.sender]);
        Transfer (this, TEAM0, balances[TEAM0]);
        Transfer (this, COMMUNITY, balances[COMMUNITY]);

    }

    //Check if team wallet is unlocked
    function unlockTeamTokens(address _address) external onlyOwner {
        if (_address == TEAM1) {
            require(BLOCK_TEAM1 <= block.number);
            require (team1Balance > 0);
            balances[TEAM1] = team1Balance;
            team1Balance = 0;
            Transfer (this, TEAM1, balances[TEAM1]);
        } else if (_address == TEAM2) {
            require(BLOCK_TEAM2 <= block.number);
            require (team2Balance > 0);
            balances[TEAM2] = team2Balance;
            team2Balance = 0;
            Transfer (this, TEAM2, balances[TEAM2]);
        }
    }

}
