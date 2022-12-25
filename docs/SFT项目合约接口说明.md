# SFT项目合约接口说明



## 1.Deposit合约

- **deposit(uint amount)**方法：质押FIL的方法，amount为质押数量。调用此方法前需要先让用户调用FIL代币合约的approve(address spender, uint amount)方法，spender填Deposit合约的地址，amount同上。

- **takeTokens**()方法：从Deposit合约中拿走所有用户质押进来的FIL代币,FIL代币将全部转给调用者。只用taker地址能调用此方法。

- **mintSFT(address[] calldata userList, uint[] calldata amountList)**方法：批量mint SFT。参数的含义为给userList[i]这个地址 mint amountList[i]个SFT代币。

  

  

## 2. Rewared合约

todo...