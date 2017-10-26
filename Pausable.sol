pragma solidity ^0.4.16;

import "./Trustable.sol";

contract Pausable is Trustable {

    //To check if Token is paused
    bool public paused;
    //Block number on pause
    uint256 public pauseBlockNumber;
    //Block number on resume
    uint256 public resumeBlockNumber;

    event Pause(uint256 _blockNumber);
    event Unpause(uint256 _blockNumber);

    function pause()
        public
        onlyOwner
        whenNotPaused
    {
        paused = true;
        pauseBlockNumber = block.number;
        resumeBlockNumber = 0;
        Pause(pauseBlockNumber);
    }

    function unpause()
        public
        onlyOwner
        whenPaused
    {
        paused = false;
        resumeBlockNumber = block.number;
        pauseBlockNumber = 0;
        Unpause(resumeBlockNumber);
    }

    modifier whenNotPaused {
        require(!paused);
        _;
    }

    modifier whenPaused {
        require(paused);
        _;
    }

}