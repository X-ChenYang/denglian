import hashlib
import time

class Blockchain(object):

    def proof_of_work(self, last_proof,valid_lenght):
        """
        简单的工作量证明:
         - 查找一个 p' 使得 hash(pp') 以4个0开头
         - p 是上一个块的证明,  p' 是当前的证明
        :param last_proof: <int>
        :param valid_lenght: <int>
        :return: <int>
        """

        proof = 0
        while self.valid_proof(last_proof, proof,valid_lenght) is False:
            proof += 1

        return proof

    @staticmethod
    def valid_proof(last_proof, proof,valid_lenght):
        """
        验证证明: 是否hash(last_proof, proof)以4个0开头?
        :param last_proof: <int> Previous Proof 前一个证明
        :param proof: <int> Current Proof 当前证明
        :return: <bool> True if correct, False if not. 匹配到返回true 否则为false
        """
        # 1. 创建验证字符串
        guess = f'{last_proof}{proof}'.encode()
        # 2. 计算哈希值
        guess_hash = hashlib.sha256(guess).hexdigest()

        # 3. 验证前4位是否为"0000"
        # 根据验证长度动态构建目标前缀，参数是valid_lenght
        target_prefix = "0" * valid_lenght
        print(f"✅ 构建的目标前缀: '{target_prefix}' (长度: {valid_lenght})")
        is_valid = guess_hash[:valid_lenght] == target_prefix
        # 4. 根据验证结果输出不同信息
        if is_valid:
            print(f"✅ 验证通过！哈希值: {guess_hash}")
        else:
            print(f"❌ 验证失败！哈希值: {guess_hash}")

        return is_valid

def main():
    print("开始计算")
    blockchain = Blockchain()
    # 获取程序开始时间
    start_time = time.time() # 返回自纪元（1970-01-01 00:00:00 UTC）以来的秒数（浮点数）
    # 获取符合【0000】的hash计算程序运行
    proof=blockchain.proof_of_work(1,3)
    # 获取程序结束时间
    end_time = time.time()

    # 计算程序运行时间
    run_time = end_time - start_time
    print(f"程序开始时间（时间戳）: {start_time}")
    print(f"程序结束时间（时间戳）: {end_time}")
    print(f"程序运行时间: {run_time:.4f} 秒")
    print(f"程序循环了: {proof} 次")


if __name__ == "__main__":
    # 安装依赖的命令（如果未安装）
    # pip install akshare pandas sqlalchemy pymysql

    # 运行主程序
    main()

