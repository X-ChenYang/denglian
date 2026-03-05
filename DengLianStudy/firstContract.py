pragma solidity ^0.8.0;

contract BalanceChecker {
    function getBalance(address addr) public view returns (uint256) {
        return addr.balance;
    }

    function getMyBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
