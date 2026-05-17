// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vault {
    using SafeERC20 for IERC20;

    IERC20 public usdc;
    uint256 public threshold;
    address[] public members;
    mapping(address => bool) public isMember;

    struct Transaction {
        address to;
        uint256 value;
        bool executed;
        uint256 approvals;
    }

    struct ScheduledPayment {
        address to;
        uint256 amount;
        uint256 interval;
        uint256 lastPaid;
        bool active;
    }

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public approved;
    
    ScheduledPayment[] public scheduledPayments;

    modifier onlyMember() {
        require(isMember[msg.sender], "Not a member");
        _;
    }

    constructor(address _usdc, address[] memory _members, uint256 _threshold) {
        require(_members.length > 0, "Members required");
        require(_threshold > 0 && _threshold <= _members.length, "Invalid threshold");
        
        usdc = IERC20(_usdc);
        threshold = _threshold;

        for (uint256 i = 0; i < _members.length; i++) {
            address member = _members[i];
            require(!isMember[member], "Duplicate member");
            isMember[member] = true;
            members.push(member);
        }
    }

    // Propose a new transaction
    function proposeTransaction(address _to, uint256 _value) public onlyMember returns (uint256) {
        uint256 txIndex = transactions.length;
        transactions.push(Transaction({
            to: _to,
            value: _value,
            executed: false,
            approvals: 0
        }));
        return txIndex;
    }

    // Approve a transaction
    function approveTransaction(uint256 _txIndex) public onlyMember {
        require(_txIndex < transactions.length, "Tx does not exist");
        require(!approved[_txIndex][msg.sender], "Already approved");
        require(!transactions[_txIndex].executed, "Already executed");

        approved[_txIndex][msg.sender] = true;
        transactions[_txIndex].approvals += 1;
    }

    // Execute a transaction once threshold is met
    function executeTransaction(uint256 _txIndex) public onlyMember {
        require(_txIndex < transactions.length, "Tx does not exist");
        require(!transactions[_txIndex].executed, "Already executed");
        require(transactions[_txIndex].approvals >= threshold, "Threshold not met");

        transactions[_txIndex].executed = true;
        usdc.safeTransfer(transactions[_txIndex].to, transactions[_txIndex].value);
    }

    // Deposit USDC into the vault
    function deposit(uint256 _amount) public {
        usdc.safeTransferFrom(msg.sender, address(this), _amount);
    }

    // Add a scheduled payment
    function addScheduledPayment(address _to, uint256 _amount, uint256 _interval) public onlyMember {
        scheduledPayments.push(ScheduledPayment({
            to: _to,
            amount: _amount,
            interval: _interval,
            lastPaid: block.timestamp,
            active: true
        }));
    }

    // Execute scheduled payment
    function executeScheduledPayment(uint256 _index) public {
        require(_index < scheduledPayments.length, "Invalid index");
        ScheduledPayment storage sp = scheduledPayments[_index];
        require(sp.active, "Not active");
        require(block.timestamp >= sp.lastPaid + sp.interval, "Too early");

        sp.lastPaid = block.timestamp;
        usdc.safeTransfer(sp.to, sp.amount);
    }
}
