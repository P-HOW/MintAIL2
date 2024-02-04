pragma solidity ^0.5.16;

import "./interfaces/IERC20.sol";

contract Lock {
    IERC20 public token;
    uint public unlockTime; // Duration in seconds
    address public owner;

    struct Deposit {
        uint amount;
        uint unlockTime; // Specific unlock time for each deposit
    }

    mapping(address => Deposit) public deposits;

    event DepositMade(address indexed depositor, uint amount, uint unlockTime);
    event Withdrawal(address indexed withdrawer, uint amount);

    constructor(IERC20 _token, address _owner, uint _unlockTime) public {
        token = _token;
        owner = _owner;
        unlockTime = _unlockTime;
    }

    // Set unlock time in seconds (e.g., 1 day = 86400 seconds)
    function setUnlockTime(uint _durationInSeconds) public {
        require(msg.sender == owner, "Only owner can set unlock time");
        unlockTime = _durationInSeconds;
    }

    function deposit(uint _amount) public {
        require(_amount > 0, "Amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        uint depositUnlockTime = block.timestamp + unlockTime;

        if (deposits[msg.sender].amount > 0) {
            deposits[msg.sender].amount += _amount;
            deposits[msg.sender].unlockTime = depositUnlockTime;
        } else {
            deposits[msg.sender] = Deposit(_amount, depositUnlockTime);
        }

        emit DepositMade(msg.sender, _amount, depositUnlockTime);
    }

    function withdraw() public {
        require(block.timestamp >= deposits[msg.sender].unlockTime, "You can't withdraw yet");
        require(deposits[msg.sender].amount > 0, "No deposit to withdraw");

        uint amount = deposits[msg.sender].amount;
        deposits[msg.sender].amount = 0;

        require(token.transfer(msg.sender, amount), "Transfer failed");

        emit Withdrawal(msg.sender, amount);
    }
}

