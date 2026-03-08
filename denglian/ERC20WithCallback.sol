// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20WithCallback is ERC20 {
    event TokensReceived(address indexed from, address indexed to, uint256 value);

    // 转账时触发回调
    function transferWithCallback(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);

        // 如果接收方是合约地址，则尝试调用其 tokensReceived 方法
        if (to.code.length > 0) {
            //msgsend在这里用户地址 address(this)在这里是代币合约地址 mytoken
            try IERC20Receiver(to).tokensReceived(msg.sender, amount) {} 
            catch {
                // 可选：如果回调失败，可以选择回滚或忽略
                revert("Callback failed and random decision chose to revert");
                // 记录失败日志，但不中断交易
                //emit CallbackFailed(msg.sender, to, amount);
                // 这里选择忽略，但可以增强错误处理
            }
        }

        emit TokensReceived(msg.sender, to, amount);
        return true;
    }

    // 接口定义用于回调
    interface IERC20Receiver {
        function tokensReceived(address from, uint256 amount) external;
    }
}