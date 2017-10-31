pragma solidity ^0.4.16;

import "./Token.sol";

/*
	Inspired by Civic and Golem

*/

/*
	Interface of migrate agent contract (the new token contract)
*/
contract MigrateAgent {

    function migrateFrom(address _tokenHolder, uint256 _amount) external returns (bool);

}

contract MigratableToken is Token {

    MigrateAgent public migrateAgent;

    //Total migrated tokens
    uint256 public totalMigrated;

    /**
     * Migrate states.
     *
     * - NotAllowed: The child contract has not reached a condition where the upgrade can bgun
     * - WaitingForAgent: Token allows upgrade, but we don't have a new agent yet
     * - ReadyToMigrate: The agent is set, but not a single token has been upgraded yet
     * - Migrating: Upgrade agent is set and the balance holders can upgrade their tokens
     *
     */
    enum MigrateState {Unknown, NotAllowed, WaitingForAgent, ReadyToMigrate, Migrating}
    event Migrate (address indexed _from, address indexed _to, uint256 _value);
    event MigrateAgentSet (address _agent);

    function migrate(uint256 _value) external {
        MigrateState state = getMigrateState();
        //Migrating has started
        require(state == MigrateState.ReadyToMigrate || state == MigrateState.Migrating);
        //Migrates user balance
        balances[msg.sender] = balances[msg.sender].SUB(_value);
        //Migrates total supply
        _totalSupply = _totalSupply.SUB(_value);
        //Counts migrated tokens
        totalMigrated = totalMigrated.ADD(_value);
        //Upgrade agent reissues the tokens
        migrateAgent.migrateFrom(msg.sender, _value);
        Migrate(msg.sender, migrateAgent, _value);
    }

    /*
        Set migrating agent and start migrating
    */
    function setMigrateAgent(MigrateAgent _agent)
    external
    onlyOwner
    notZeroAddress(_agent)
    afterCrowdsale
    {
        //cannot interrupt migrating
        require(getMigrateState() != MigrateState.Migrating);
        //set migrate agent
        migrateAgent = _agent;
        //Emit event
        MigrateAgentSet(migrateAgent);
    }

    /*
        Migrating status
    */
    function getMigrateState() public constant returns (MigrateState) {
        if (block.number <= crowdsaleEndBlock) {
            //Migration is not allowed on funding
            return MigrateState.NotAllowed;
        } else if (address(migrateAgent) == address(0)) {
            //Migrating address is not set
            return MigrateState.WaitingForAgent;
        } else if (totalMigrated == 0) {
            //Migrating hasn't started yet
            return MigrateState.ReadyToMigrate;
        } else {
            //Migrating
            return MigrateState.Migrating;
        }

    }

}