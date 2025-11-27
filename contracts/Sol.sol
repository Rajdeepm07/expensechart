// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title SimpleExpenseChart
/// @notice Minimal expense tracker / chart-friendly contract. No deployment inputs.
contract SimpleExpenseChart {
    address public owner;
    uint256 private nextId;

    struct Expense {
        uint256 id;
        string title;
        uint256 amount;     // store in smallest unit (wei / cents) depending on your usage
        uint256 timestamp;  // block timestamp when added
    }

    // id => Expense
    mapping(uint256 => Expense) private expenses;
    // keep order of ids for enumeration
    uint256[] private expenseIds;

    event ExpenseAdded(uint256 indexed id, string title, uint256 amount, uint256 timestamp);
    event ExpenseRemoved(uint256 indexed id);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        nextId = 1;
    }

    /// @notice Add a new expense (owner only)
    /// @param title short description (e.g., "lunch", "rent")
    /// @param amount numeric amount (use smallest unit you decide — e.g., paise or wei)
    function addExpense(string calldata title, uint256 amount) external onlyOwner {
        uint256 id = nextId++;
        Expense memory e = Expense({
            id: id,
            title: title,
            amount: amount,
            timestamp: block.timestamp
        });
        expenses[id] = e;
        expenseIds.push(id);
        emit ExpenseAdded(id, title, amount, block.timestamp);
    }

    /// @notice Remove an expense by id (owner only)
    /// @dev does not compact expenseIds array to keep implementation simple
    function removeExpense(uint256 id) external onlyOwner {
        require(expenses[id].id != 0, "not found");
        delete expenses[id];
        emit ExpenseRemoved(id);
    }

    /// @notice Get a single expense
    function getExpense(uint256 id) external view returns (Expense memory) {
        require(expenses[id].id != 0, "not found");
        return expenses[id];
    }

    /// @notice Get list of all expense IDs (use this to fetch each expense off-chain)
    function getExpenseIds() external view returns (uint256[] memory) {
        return expenseIds;
    }

    /// @notice Get total of all stored expenses
    function totalExpenses() external view returns (uint256 total) {
        for (uint256 i = 0; i < expenseIds.length; i++) {
            uint256 id = expenseIds[i];
            if (expenses[id].id != 0) {
                total += expenses[id].amount;
            }
        }
    }

    /// @notice Change owner if needed
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "invalid owner");
        owner = newOwner;
    }
}
