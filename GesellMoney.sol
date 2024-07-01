// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

contract GesellMoney {
    mapping (address => uint256) public balance;
    mapping (address => uint256) private lastUpdate;

    uint256 public demurrageRate = 1; // Демередж в % за год
    uint256 public demurrageInterval = 365 days; // Интервал обновления

    event Transfer(address indexed from, address indexed to, uint256 value);

    function updateBalance(address user) public {
        uint256 heldDuration = block.timestamp - lastUpdate[user];
        if(heldDuration > demurrageInterval) {
            uint256 year = heldDuration / demurrageInterval;
            uint256 decayAmount = balance[user] * demurrageRate / 100 * year;
            balance[user] -= decayAmount;
            lastUpdate[user] = block.timestamp;
        }
    }

    function transfer(address to, uint256 amount) public {
        updateBalance(msg.sender);
        updateBalance(to);
        require(balance[msg.sender] >= amount, "Insufficient balance");
        balance[msg.sender] -= amount;
        balance[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function deposit() public payable {
        updateBalance(msg.sender);
        balance[msg.sender] += msg.value;
        lastUpdate[msg.sender] = block.timestamp;
    }

    function withdraw(uint256 amount) public {
        updateBalance(msg.sender);
        require(balance[msg.sender] >= amount, "Insufficient balance");
        balance[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
}