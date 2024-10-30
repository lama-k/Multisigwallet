pragma solidity ^0.8.7;
import "./Ownable.sol";

contract Destroyable is Ownable {
    function close() public onlyCreator {
        selfdestruct(payable(creator));
    }
}
