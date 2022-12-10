// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interface/ISFTToken.sol";


contract Deposit is Ownable2StepUpgradeable {
    using SafeERC20 for IERC20;

    struct UserDeposit {
        uint depositedAmount;
        uint pendingAmount;
    }

    struct WithdrawApplication {
        bytes32 applyId;
        address user;
        uint amount;
        uint nonce;
        bool processed; // false:未处理，true：已处理
        uint applyTime;
    }

 
    IERC20 public filToken;
    ISFTToken public sftToken;
    address public oracle;
    bool public mutex;
    uint public applyCount;
    uint public demandDepositLimit; //质押上限
    uint public demandTotalAmount; //总质押数
    address[] public depositedList; //有deposited状态代币的address列表
    address[] public pendingList;  // 有pending状态代币的address列表

    mapping (address => UserDeposit) public userDeposit; // 用户质押状态
    mapping (address => bool) public authority; // 提币权限
    mapping (address => bool) public approver; // 提币批准人
    mapping (address => bytes32[]) userApplications; // user address => applyId
    mapping (bytes32 => WithdrawApplication) withdrawApplication;

    event DemandDeposit(address indexed user, uint amount);
    event SetAuthority(address indexed account, bool authorized);
    event SetApprover(address indexed account, bool authorized);
    event TakeTokens(address indexed authority, uint amount);
    event SetOracle (address oldOracle, address newOracle);
    event SetDemandDepositLimit(uint oldDemandDepositLimit, uint newDemandDepositLimit);
    event ApplyWithdraw(bytes32 applyId, address indexed user, uint amount, uint applyTime);
    event Withdraw(bytes32 applyId, address indexed user, uint amount, uint timestamp);

    function initialize(IERC20 _filToken, ISFTToken _sftToken, address _authority, address _approver, address _oracle, uint _demandDepositLimit, bool _mutex, uint _applyCount) external initializer {
        require(address(_filToken) != address(0), "fil token address cannot be zero");
        require(address(_sftToken) != address(0), "SFT token address cannot be zero");
        __Context_init_unchained();
        __Ownable_init_unchained();
        filToken = _filToken;
        sftToken = _sftToken;
        mutex = _mutex;
        applyCount = _applyCount;
        _setAuthority(_authority, true);
        _setApprover(_approver, true);
        _setOracle(_oracle);
        _setDemandDepositLimit(_demandDepositLimit);
    }

    function setDemandDepositLimit(uint newemandDepositLimit) external onlyOwner {
        _setDemandDepositLimit(newemandDepositLimit);
    }

    function _setDemandDepositLimit(uint _demandDepositLimit) private {
        emit SetDemandDepositLimit(demandDepositLimit, _demandDepositLimit);
        demandDepositLimit = _demandDepositLimit;
    }

    function setApprover(address _approver, bool _authorized) external onlyOwner {
        _setApprover(_approver, _authorized);
    }

    function _setApprover(address _approver, bool _authorized) private {
        require(_approver != address(0), "empty approver");
        approver[_approver] = _authorized;
        emit SetApprover(_approver, _authorized);
    }


    function setAuthority(address _authority, bool _authorized) external onlyOwner {
        _setAuthority(_authority, _authorized);
    }

    function _setAuthority(address _authority, bool _authorized) private {
        require(_authority != address(0), "empty authority");
        authority[_authority] = _authorized;
        emit SetAuthority(_authority, _authorized);
    }

    function setOracle(address newOracle) external onlyOwner {
        _setOracle(newOracle);
    }

    function _setOracle(address _oracle) private {
        require(_oracle != address(0), "empty oracle");
        emit SetOracle(oracle, _oracle);
        oracle = _oracle;
    }
    
    // 质押
    function demandDeposit(uint amount) external {
        require(filToken.balanceOf(address(msg.sender)) >= amount, "fil balance not enough");
        require(amount + demandTotalAmount <= demandDepositLimit, "exceed deposit limit");
        filToken.safeTransferFrom(address(msg.sender), address(this), amount);
        UserDeposit storage user = userDeposit[address(msg.sender)];
        if (user.depositedAmount == 0) {
            depositedList.push(address(msg.sender));
        } 
        user.depositedAmount += amount;
        demandTotalAmount += amount;
        emit DemandDeposit(msg.sender, amount);
    }

    // 取走质押的fil，拿去做节点
    function takeTokens() external {
        require(authority[msg.sender], "!authority");
        require(mutex, "locked!");
        mutex = false;
        if (depositedList.length == 0) {
            return;
        }
        uint remainTokens = 0;
        for(uint i = 0; i < depositedList.length; i++) {
            UserDeposit storage user = userDeposit[depositedList[i]];
            if (user.pendingAmount == 0) {
                pendingList.push(depositedList[i]);
            }
            uint depositedAmount = user.depositedAmount; // save gas
            user.pendingAmount += depositedAmount;
            user.depositedAmount = 0;
            remainTokens += depositedAmount;
        }
        require(filToken.balanceOf(address(this)) >= remainTokens, "incorrect balance");
        delete depositedList;
        filToken.safeTransfer(address(msg.sender), remainTokens);
        emit TakeTokens(address(msg.sender), remainTokens);
    }

    // 节点封装完成
    function staked() external {
        require(address(msg.sender) == oracle, "only oracle can call");
        require(!mutex, "locked!");
        mutex = true;
        if (pendingList.length == 0) {
            return;
        }
        for (uint i = 0; i < pendingList.length; i++) {
            UserDeposit storage user = userDeposit[pendingList[i]];
            uint pendingAmount = user.pendingAmount; // save gas
            user.pendingAmount = 0;
            sftToken.mint(pendingList[i], pendingAmount);
        }
        delete pendingList;
    }

    // 申请取款
    function applyWithdraw(uint amount) external {
        require(sftToken.balanceOf(address(msg.sender)) >= amount, "sft token balance not enough");
        require(sftToken.transferFrom(address(msg.sender), address(this), amount), "tranfer fialed");
        uint nonce = applyCount;
        applyCount += 1;
        bytes32 applyId = keccak256(abi.encodePacked(address(msg.sender), nonce));
        WithdrawApplication storage appliaction =  withdrawApplication[applyId];
        appliaction.applyId = applyId;
        appliaction.user = address(msg.sender);
        appliaction.amount = amount;
        appliaction.processed = false;
        appliaction.nonce = nonce;
        appliaction.applyTime = block.timestamp;
        userApplications[address(msg.sender)].push(applyId);
        emit ApplyWithdraw(applyId, address(msg.sender), amount, block.timestamp);
    }

    // 批准提款
    function approveWithdraw(bytes32 applyId) external {
        require(approver[address(msg.sender)], "not approver");
        require(!withdrawApplication[applyId].processed, "already processed");
        WithdrawApplication storage application = withdrawApplication[applyId];
        uint withdrawAmount = application.amount; // save gas
        address user = application.user;
        require(sftToken.balanceOf(address(this)) >= withdrawAmount, "incorrect sft token balance");
        require(filToken.balanceOf(address(msg.sender)) >= withdrawAmount, "fil token balacne not enough");
        application.processed = true;
        filToken.safeTransferFrom(address(msg.sender), user, withdrawAmount);
        sftToken.burn(withdrawAmount);
        emit Withdraw(applyId, user, withdrawAmount, block.timestamp);
    }
}