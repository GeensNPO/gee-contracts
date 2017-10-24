pragma solidity ^0.4.16;

import "./Ownable.sol";
import "./SafeMath.sol";


/*
	Interface of GeeToken contract
*/
contract Token {

    function transfer(address _to, uint256 _value);

    function burn(uint256 _value);

}

contract Crowdsale is Ownable {

    using SafeMath for uint256;

    //Counts how many Gee coins are sold
    uint256 public sold;
    //Hard cap in Gee coins (with 8 decimals)
    uint256 public hardCapInToken = 67 * (10**6) * (10**8);
    //Min amount of Ether
    uint256 public constant minEther = 0.03 ether;
    //Max amount of Ether
    uint256 public constant maxEther = 1000 ether;

    //Address where funds are forwarded during the ICO
    address fund = 0x77E32B38a4AfdAb4dA3863a1de198809170644Df;

    //Mined blocks per day
    uint256 public constant day = 5082;

    //Start block
    uint256 public constant startBlockNumber = 4506960;
    //Start + 3 days
    uint256 public tier2 = startBlockNumber.ADD(day.MUL(3));
    //Start + 10 days ( 3 days + 7 days)
    uint256 public tier3 = startBlockNumber.ADD(day.MUL(10));
    //Start + 20 days ( 3 days + 7 days + 10 days)
    uint256 public tier4 = startBlockNumber.ADD(day.MUL(20));
    //Start + 30 days
    uint256 public endBlockNumber = startBlockNumber.ADD(day.MUL(30));

    //Price at the beginning
    uint256 public price;
    //Price in 1st tier
    uint256 public constant tier1Price = 6000000;
    //Price in 2nd tier
    uint256 public constant tier2Price = 6700000;
    //Price in 3rd tier
    uint256 public constant tier3Price = 7400000;
    //Price in 4th tier
    uint256 public constant tier4Price = 8200000;

    //GeeToken contract
    Token public gee;

    //softcap in ETH
    uint256 public constant softCapInEther = 13500 ether;
    //saves how mush ETH user spent on GEE
    mapping (address => uint256) public bought;
    //saves how mush ETH was collected
    uint256 public collected;

    //
    bool public stopped = false;


    uint256 public constant gee100 = 100 * (10**8);

    //Keep track of buyings
    event Buy (address indexed _who, uint256 _amount, uint256 indexed _price);
    event ChangeFund (address indexed _fund);
    event Refund (address indexed _who, uint256 _amount);

    //Payable - can store ETH
    function Crowdsale(Token _geeToken)
        notZeroAddress(_geeToken)
        payable
    {
        gee = _geeToken;
    }

    /*
        Fallback function is called when Ether is sent to the contract
    */
    function() payable {
        if (isCrowdsaleActive()) {
            buy();
        } else { //after crowdsale owner can send back eth for refund
            require (msg.sender == owner);
        }
    }

    /*
        Owner can change fund address
    */
    function changeFund(address _fund)
    external
    notZeroAddress(_fund)
    onlyOwner
    {
        fund = _fund;
        ChangeFund (_fund);
    }


    /*
        Get unsold Gee coins when the Crowdsale ended
    */
    function finalize() external  {
        if (sold < (hardCapInToken - gee100)) {
            require(block.number > endBlockNumber);
        }
        require(sold != hardCapInToken);
        gee.burn(hardCapInToken.SUB(sold));
        hardCapInToken = sold;
    }


    function buy()
    public
    payable
    {
        uint256 amountWei = msg.value;
        uint256 blocks = block.number;

        //Is crowdsale started
        require(startBlockNumber <= blocks);
        //Is crowdsale ended
        require(endBlockNumber >= blocks);
        //Ether limitation
        require(amountWei >= minEther);
        require(amountWei <= maxEther);

        price = getPrice();
        //Count how many GEE sender can buy
        uint256 amount = amountWei / price;
        //Add amount to sold
        sold = sold.ADD(amount);

        require(sold <= hardCapInToken);

        if (sold == hardCapInToken) {
            endBlockNumber = blocks;
        }

        //counts ETH
        collected = collected.ADD(amountWei);
        bought[msg.sender] = bought[msg.sender].ADD(amountWei);

        //Transfer amount of Gee coins to msg.sender
        gee.transfer(msg.sender, amount);

        //Transfer contract Ether to Geens
        fund.transfer(this.balance);
        Buy(msg.sender, amount, price);
    }


    /*
        Function returns if Crowdsale is ongoing
    */
    function isCrowdsaleActive() public constant returns (bool) {

        if (endBlockNumber < block.number || stopped || startBlockNumber > block.number){
            return false;
        }
        return true;
    }

    /*
        Function which automatically changes tiers
    */
    function getPrice()
    internal
    constant
    returns (uint256)
    {
        if (block.number >= tier4) {
            return tier4Price;
        } else if (block.number >= tier3){
            return tier3Price;
        } else if (block.number >= tier2){
            return tier2Price;
        }

        return tier1Price;
    }

    function stopInEmergency () external onlyOwner {
        require (!stopped);
        stopped = true;
    }

    function refund() external
    {
        uint256 refund = bought[msg.sender];
        require (!isCrowdsaleActive());
        require (collected < softCapInEther || stopped);
        bought[msg.sender] = 0;
        msg.sender.transfer(refund);
        Refund(msg.sender, refund);
    }
}