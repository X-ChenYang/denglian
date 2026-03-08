// 假设原始 TokenBank 简单结构
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract TokenBank {
    mapping(address => uint256) public balances;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function depositERC20(address token, uint256 amount) external {
        require(token != address(0), "Invalid token address");
        // 假设用户已批准
        ERC20(token).transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
    }
}