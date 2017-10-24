pragma solidity ^0.4.16;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /*
        @return sum of a and b
    */
    function ADD (uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    /*
        @return difference of a and b
    */
    function SUB (uint256 a, uint256 b) internal returns (uint256)  {
        assert(a >= b);
        return a - b;
    }

    /*
        @return multiples a and b
    */
    function MUL (uint256 a, uint256 b) internal returns (uint256)  {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    
}