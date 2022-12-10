// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interface/ISFTToken.sol";


contract Reward is Ownable2StepUpgradeable {
    using SafeERC20 for IERC20;
    struct UserInfo {
        uint amount;
        uint lastUpdateBlock;
        uint accRewards;
    }

    IERC20 public filToken;
    ISFTToken public sftToken;

    uint public rewardUnit; // fil reward per block per sft token
    mapping (address => UserInfo) public userInfo; 

    event Stake(address indexed user, uint amount);
    event Unstake(address indexed user, uint amount);
    event Claim(address indexed user, uint amount);
    event SetRewardUnit(uint oldRewardUnit, uint newRewardUnit);
    event TokensRescued(address indexed to, address indexed token, uint256 amount);

    function initialize(IERC20 _filToken, ISFTToken _sftToken, uint _rewardUnit) external initializer {
        require(address(_filToken) != address(0), "fil token address cannot be zero");
        require(address(_sftToken) != address(0), "SFT token address cannot be zero");
        __Context_init_unchained();
        __Ownable_init_unchained();
        filToken = _filToken;
        sftToken = _sftToken;
        _setRewardUnit(_rewardUnit);
    }

    function setRewardUnit(uint newRewardUnit) external onlyOwner {
        _setRewardUnit(newRewardUnit);
    }

    function _setRewardUnit(uint _rewardUnit) private {
        emit SetRewardUnit(rewardUnit, _rewardUnit);
        rewardUnit = _rewardUnit;
    }

    // 查询用户当前的收益
    function pendingRewards(address account) external view returns(uint) {
        UserInfo memory user = userInfo[account];
        uint accRewards = user.accRewards;
        if (user.amount > 0 && block.number > user.lastUpdateBlock) {
            uint blockDelta = block.number - user.lastUpdateBlock;
            uint rewards = (user.amount * blockDelta * rewardUnit) / 1e18;
            accRewards += rewards;
        }
        return accRewards;
    }

    // 质押
    function stake(uint amount) external {
        require(sftToken.balanceOf(address(msg.sender)) >= amount, "stake: sft token banlance not enough");
        require(sftToken.transferFrom(address(msg.sender),address(this), amount), "stake: transfer failed");
        UserInfo storage user = userInfo[address(msg.sender)];
        uint userAmount = user.amount; // save gas
        uint lastUpdateBlock = user.lastUpdateBlock; // save gas
        if (userAmount > 0 && block.number > lastUpdateBlock) {
            uint rewards = (userAmount * (block.number - lastUpdateBlock) * rewardUnit) / 1e18;
            user.accRewards += rewards;
        }
        user.amount += amount;
        user.lastUpdateBlock = block.number;
        emit Stake(address(msg.sender), amount);
    }

    // 解质押
    function unstake(uint amount) external {
        UserInfo storage user = userInfo[address(msg.sender)];
        uint userAmount = user.amount;
        require(userAmount >= amount, "unstake: balance not enough");
        uint lastUpdateBlock = user.lastUpdateBlock;
        if (userAmount > 0 && block.number > lastUpdateBlock) {
            uint rewards = (userAmount * (block.number - lastUpdateBlock) * rewardUnit) / 1e18;
            user.accRewards += rewards; 
        }
        user.amount -= amount;
        user.lastUpdateBlock = block.number;
        require(sftToken.transfer(address(msg.sender), amount), "unstake: transfer fialed");
        emit Unstake(address(msg.sender), amount);
    }

    // 领取收益
    function claim(uint amount) external {
        UserInfo storage user = userInfo[address(msg.sender)];
        uint accRewards = user.accRewards;
        if (user.amount > 0 && block.number > user.lastUpdateBlock) {
            uint blockDelta = block.number - user.lastUpdateBlock;
            uint rewards = (user.amount * blockDelta * rewardUnit) / 1e18;
            accRewards += rewards;
        }
        require(accRewards >= amount, "claim: balance not enough");
        user.accRewards = accRewards - amount;
        user.lastUpdateBlock = block.number;
        filToken.safeTransfer(address(msg.sender), amount);
        emit Claim(address(msg.sender), amount);
    }

    // 提取误转入的代币
    function rescueTokens(
        address _to,
        address _token,
        uint256 _amount
    ) external onlyOwner {
        require(_to != address(0), "Cannot send to address(0)");
        require(_amount != 0, "Cannot rescue 0 tokens");
        IERC20 token = IERC20(_token);
        token.safeTransfer(_to, _amount);
        emit TokensRescued(_to, _token, _amount);
    }
}