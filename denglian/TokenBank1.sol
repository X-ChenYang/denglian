pragma solidity ^0.8.0;

// ============= ERC20 接口（最小必要实现） =============
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

// ============= TokenBank 合约 =============
contract TokenBank {
    IERC20 public immutable token; // 存储的 Token 地址（部署时指定）
    mapping(address => uint256) public userBalances; // 记录每个用户的存款余额

    // 事件：存款、取款
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    // 构造函数：指定要管理的 ERC20 Token 地址
    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "Token address cannot be zero");
        token = IERC20(_tokenAddress);
    }

    /**
     * @dev 存入指定数量的 Token
     * @param amount 存入数量（必须 > 0）
     * 用户需提前调用 Token.approve(address(this), amount) 授权
     */
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        
        // 从用户账户转移 Token 到本合约（需用户提前授权）
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "TransferFrom failed"
        );
        
        // 更新用户余额记录
        userBalances[msg.sender] += amount;
        
        emit Deposited(msg.sender, amount);
    }

    /**
     * @dev 取出指定数量的 Token
     * @param amount 取出数量（必须 > 0 且 ≤ 用户余额）
     */
    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(
            userBalances[msg.sender] >= amount,
            "Insufficient balance in TokenBank"
        );
        
        // 更新余额记录（防重入关键：先减后转）
        userBalances[msg.sender] -= amount;
        
        // 将 Token 转回用户账户
        require(
            token.transfer(msg.sender, amount),
            "Transfer failed"
        );
        
        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev 查询用户在 TokenBank 中的可用余额
     */
    function getBalance(address user) external view returns (uint256) {
        return userBalances[user];
    }
}