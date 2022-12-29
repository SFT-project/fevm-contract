# SFT项目合约接口说明



## 1.Deposit合约

- **deposit(uint amount)**方法：质押FIL的方法，amount为质押数量。调用此方法前需要先让用户调用FIL代币合约的approve(address spender, uint amount)方法，spender填Deposit合约的地址，amount同上。

- **takeTokens**()方法：从Deposit合约中拿走所有用户质押进来的FIL代币,FIL代币将全部转给调用者。只用taker地址能调用此方法。

- **mintSFT(address[] calldata userList, uint[] calldata amountList)**方法：批量mint SFT。参数的含义为给userList[i]这个地址 mint amountList[i]个SFT代币。

  

  

## 2. Rewared合约

**注：**pid表示池子的id，0表示活期，1表示三个月定期。index表示用户在某个池子质押记录的索引号，从0开始递增。用户在活期池子里的质押记录永远只有一条，即每个用户在0号池子的index恒为0（如果有质押的话）。

- **pools(uint pid)**:根据pid返回池子的锁仓时间，单位秒。

- **userInfo(address user, uint pid, uint index)**: 返回user在第pid号池子索引号为index的锁仓信息，返回内容为如下LockInfo结构体：

  ```solidity
  struct LockInfo {
          uint amount; 
          uint stakeAt; // 质押时间
          uint lockPeriod; // 锁仓期限
          uint totalRewards; // 总奖励
          uint unclaimedRewards; // 未领取奖励
      }
  ```

- **getUserInfo(address user, uint pid)**: 返回user在第pid号池子的所有锁仓记录，返回内容为一个LockInfo数组。
- **stake(uint pid, uint amout)**: 向第pid个池子质押SFT,数量为amount（注意精度为18位）。调用此方法前需要先让用户调用SFT代币合约的approve(address spender, uint amount)方法，spender填Reward合约的地址，amount同上。
- **unstake(uint pid, uint index, uint amount)**: 解除第pid号池子，索引号为index的质押，数量为amount。
- **claim(uint pid, uint index, uint amount)**：领取第pid号池子，索引号为index的质押奖励，数量为amount。
- **distributeReward**(address[] calldata userList, uint[] calldata pidList, uint[] calldata indexList, uint[] calldata rewardList, uint totalRewards)：此方法用于向用户发放质押奖励，同时将作为奖励发放的FIL转到Reward合约中。参数含义为:向用户useList[i]在第pidList[i]号池子中，索引号为indexList[i]的质押发放rewardList[i]个FIL（精度为18位）奖励，同时将totalRewards个FIL转到Reward合约中。此方法只有distributor角色才能调用，调用前，distributor要先调用FIL代币合约的approve(address spender, uint amount)方法，spender填Reward合约的地址，amount为totalRewards(如果不想每次都调approve，也可以填一个很大的数），同时，需要确保distributor地址里FIL的余额要大于totalRewards。



