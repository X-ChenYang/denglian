// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20WithCallback.sol"; // 上面定义的扩展 ERC20

contract TokenBankV2 is TokenBank {
    // 存储每个用户的余额（按 token 地址分）
    mapping(address => mapping(address => uint256)) private userBalances;
    // 白名单：允许哪些代币合约可以触发回调
    mapping(address => bool) public allowedTokens;
    address public owner;

    constructor() {
        //这里的msgsend是指部署的用户地址 不是tokenbank的地址 也不是代币地址 如果是在新new一个tokenbank，那么settokenban就会报错
        //因为owner是部署着地址，调用这个方法的事新创建的地址就会报错，msgsend是新创建的tokenbankd地址和owner不一致，注意msgsend的地址
        owner = msg.sender;
    }

    // 允许管理员添加或移除允许的代币
    function setAllowedToken(address token, bool isAllowed) external {
        require(msg.sender == owner, "Only owner can modify allowed tokens");
        allowedTokens[token] = isAllowed;
    }
    // 支持多种代币
    function depositERC20(address token, uint256 amount) external override {
        require(token != address(0), "Invalid token address");
        ERC20(token).transferFrom(msg.sender, address(this), amount);
        userBalances[token][msg.sender] += amount;
    }

    // 实现 tokensReceived 回调函数
    function tokensReceived(address from, uint256 amount) external {
        //错误代码  msgsender 在这里是 mytoken地址，address（this）是tokenbank地址，
        require(
            msg.sender == address(this),
            "Only this contract can receive callback"
        );
        // ① 检查调用者是否为允许的代币合约
        require(allowedTokens[msg.sender], "Unauthorized token");
        // 获取代币地址（即调用者）
        address token = msg.sender;

        // 记录存款
        userBalances[token][from] += amount;

        // 可选：记录事件
        emit Deposit(from, token, amount);
    }

    // 事件：存款记录
    event Deposit(address indexed user, address indexed token, uint256 amount);

    // 查询用户在某个代币上的余额
    function balanceOf(
        address user,
        address token
    ) public view returns (uint256) {
        return userBalances[token][user];
    }

    // 示例：允许用户提取代币
    function withdrawERC20(address token, uint256 amount) external {
        require(
            userBalances[token][msg.sender] >= amount,
            "Insufficient balance"
        );
        ERC20(token).transfer(msg.sender, amount);
        userBalances[token][msg.sender] -= amount;
    }
    
}
