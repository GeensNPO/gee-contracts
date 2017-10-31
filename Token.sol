pragma solidity ^0.4.16;

import "./Pausable.sol";
import "./SafeMath.sol";
import "./ERC20.sol";

/*
	Contract determines token
*/
contract Token is ERC20, Pausable {


    using SafeMath for uint256;

    //Total amount of Gee
    uint256 public _totalSupply = 100 * (10**6) * (10**8);

    //end of crowdsale
    uint256 public crowdsaleEndBlock = 222222222;
    //end of crowdsale
    uint256 public constant crowdsaleMaxEndBlock = 444444444;

    //Balances for each account
    mapping (address => uint256)  balances;
    //Owner of the account approves the transfer of an amount to another account
    mapping (address => mapping (address => uint256)) allowed;

    //Notifies users about the amount burnt
    event Burn(address indexed _from, uint256 _value);

    //return _totalSupply of the Token
    function totalSupply() external constant returns (uint256 totalTokenSupply) {
        totalTokenSupply = _totalSupply;
    }

    //What is the balance of a particular account?
    function balanceOf(address _owner)
        external
        constant
        returns (uint256 balance)
    {
        return balances[_owner];
    }

    //Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount)
        external
        notZeroAddress(_to)
        whenNotPaused
        canTransferOnCrowdsale(msg.sender)
        returns (bool success)
    {
        balances[msg.sender] = balances[msg.sender].SUB(_amount);
        balances[_to] = balances[_to].ADD(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(address _from, address _to, uint256 _amount)
        external
        notZeroAddress(_to)
        whenNotPaused
        canTransferOnCrowdsale(msg.sender)
        canTransferOnCrowdsale(_from)
        returns (bool success)
    {
        //Require allowance to be not too big
        require(allowed[_from][msg.sender] >= _amount);
        balances[_from] = balances[_from].SUB(_amount);
        balances[_to] = balances[_to].ADD(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].SUB(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount)
        external
        whenNotPaused
        notZeroAddress(_spender)
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    //Return how many tokens left that you can spend from
    function allowance(address _owner, address _spender)
        external
        constant
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    /**
     * To increment allowed value is better to use this function to avoid 2 calls
     * From MonolithDAO Token.sol
     */

    function increaseApproval(address _spender, uint256 _addedValue)
        external
        whenNotPaused
        returns (bool success)
    {
        uint256 increased = allowed[msg.sender][_spender].ADD(_addedValue);
        require(increased <= balances[msg.sender]);
        //Cannot approve more coins then you have
        allowed[msg.sender][_spender] = increased;
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue)
        external
        whenNotPaused
        returns (bool success)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.SUB(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function burn(uint256 _value) external returns (bool success) {
        require(trusted[msg.sender]);
        //Subtract from the sender
        balances[msg.sender] = balances[msg.sender].SUB(_value);
        //Update _totalSupply
        _totalSupply = _totalSupply.SUB(_value);
        Burn(msg.sender, _value);
        return true;
    }

    function updateCrowdsaleEndBlock (uint256 _crowdsaleEndBlock) {
        //Crowdsale must be active
        require(block.number <= crowdsaleEndBlock);
        //Transfers can only be unlocked earlier
        require(_crowdsaleEndBlock < crowdsaleMaxEndBlock);
        crowdsaleEndBlock = _crowdsaleEndBlock;
    }

    //Override transferOwnership()
    function transferOwnership(address _newOwner) public afterCrowdsale {
        super.transferOwnership(_newOwner);
    }

    //Override pause()
    function pause() public afterCrowdsale {
        super.pause();
    }

    modifier canTransferOnCrowdsale (address _address) {
        if (block.number <= crowdsaleEndBlock) {
            //Require the end of funding or msg.sender to be trusted
            require(trusted[_address]);
        }
        _;
    }

    //Some functions should work only after the Crowdsale
    modifier afterCrowdsale {
        require(block.number > crowdsaleEndBlock);
        _;
    }

}