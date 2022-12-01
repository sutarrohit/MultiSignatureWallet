//SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;

contract MultiSigWallet {
    /**Events*/

    //Event is triggered when ETH is deposited.
    event Deposit(address indexed sender, uint256 amount);

    //Event is triggered when transaction is submited and waiting for other owners confirmation.
    event SubmitTransactoin(uint256 indexed txId);

    //Event is triggered when other owner approved the transaction.
    event ApprovedTransaction(address indexed owner, uint256 indexed txId);

    //Event is triggered when owner revoke the transaction approval.
    event RevokeTransaction(address indexed owner, uint256 indexed txId);

    //Event is triggered when the transaction is executed.
    event ExecuteTransaction(address indexed owner, uint256 indexed txId);

    /**Modifiers*/
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    modifier txExists(uint256 _txId) {
        require(_txId < transaction.length, "tx does not exxits");
        _;
    }

    modifier notApproved(uint256 _txId) {
        require(!approved[_txId][msg.sender], "Transaction has already approved");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        require(!transaction[_txId].executed, "Transaction has already approved");
        _;
    }

    /**Struct to store transaction*/
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    /**State variables*/
    address[] public owners;
    //If msg.sender is owner it return true
    mapping(address => bool) isOwner;
    uint256 public numOfConfirmationRequired;

    //Array to store tranactions struct
    Transaction[] public transaction;

    //map Transaction array index to owner's approval
    mapping(uint256 => mapping(address => bool)) public approved;

    constructor(address[] memory _owner, uint256 _numOfConfirmationRequired) {
        require(_owner.length > 0, "Owner Required");
        require(_numOfConfirmationRequired > 0 && _numOfConfirmationRequired <= _owner.length);

        for (uint256 i; i < _owner.length; i++) {
            address owner = _owner[i];
            require(owner != address(0), "Invalid Owner");

            isOwner[owner] = true;
            //Store owner in the Owners array
            owners.push(owner);
        }

        numOfConfirmationRequired = _numOfConfirmationRequired;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    //Function for owners to submit transaction
    function submitTransaction(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner {
        //store submited transaction in the array
        transaction.push(Transaction({to: _to, value: _value, data: _data, executed: false}));

        emit SubmitTransactoin(transaction.length - 1);
    }

    //Owner can approve transaction
    function approveTransaction(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notApproved(_txId)
        notExecuted(_txId)
    {
        approved[_txId][msg.sender] = true;
        emit ApprovedTransaction(msg.sender, _txId);
    }

    //Fuction retrune how many owner approved transaction
    function _getApprovalCount(uint256 _txId) internal view returns (uint256 count) {
        for (uint256 i; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) {
                count += 1;
            }
        }
    }

    //This function check if all owner approved or not and send ETH to recipient
    function executeTransaction(uint256 _txId) external txExists(_txId) notExecuted(_txId) {
        require(_getApprovalCount(_txId) >= numOfConfirmationRequired, "Approval required");

        Transaction storage transactions = transaction[_txId];
        transactions.executed = true;

        (bool success, ) = transactions.to.call{value: transactions.value}(transactions.data);
        require(success, "Transaction Failed");

        emit ExecuteTransaction(msg.sender, _txId);
    }

    //Owner can revoke approval of the tranction
    function revokeConfirmation(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
    {
        require(approved[_txId][msg.sender], "Transaction not approved");
        approved[_txId][msg.sender] = false;
        emit RevokeTransaction(msg.sender, _txId);
    }
}

//Contract Address: 0x75947ad6ddadd6dB97EA88226f47Bb86D3EAaB53
