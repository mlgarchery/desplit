//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


contract Desplit {
    mapping(uint256 => DesplitGroup) public groups;
    uint256 public groupCount;

    constructor() {
        groupCount = 0;
    }

    function createGroup(address[] memory _addresses) public {
        groups[groupCount] = new DesplitGroup(msg.sender, _addresses);
        groupCount++;
    }
}

contract DesplitGroup {
    address public creator;
    address[] public addresses;
    Request public request;
    // TODO we need a list of txs
    mapping(address => int256) public balances;

    constructor(address _creator, address[] memory _addresses) {
        creator = _creator;
        addresses = _addresses;
    }

    function getBalance(address _address) public view returns (int256) {
        return balances[_address];
    }

    function addToBalance(address _address, int256 _amount) public {
        // TODO check that _address is in addresses
        int256 amount = balances[_address] + _amount;
        setBalance(_address, amount);
    }

    function setBalance(address _address, int256 amount) private {
        balances[_address] = amount;
    }

    function createPaymentRequest(
        IERC20 _tokenAddress,
        address recipient,
        uint256 amount
    ) public {
        request = Request(
            msg.sender,
            recipient,
            amount,
            new Approbations(addresses.length),
            _tokenAddress
        );
        validate(true); // sender is validating by default
    }

    function validate(bool b) public {
        for (uint256 i = 0; i < addresses.length; i++) {
            if (msg.sender == addresses[i]) {
                request.approbations.approve(i, b);
            }
        }
        // check that everyone approved the transaction
        if (request.approbations.allApproved()) {
            request.tokenAddress.transferFrom(
                request.sender,
                request.recipient,
                request.amount
            );
        }
    }
    // TODO how to send notifications
}

struct Request {
    address sender;
    address recipient;
    uint256 amount;
    Approbations approbations;
    IERC20 tokenAddress;
}

contract Approbations {
    bool[] public approbations;
    bool public all_approved;

    constructor(uint256 size) {
        approbations = new bool[](size);
        all_approved = false;
    }

    function approve(uint256 i, bool b) public {
        approbations[i] = b;
    }

    function allApproved() public view returns (bool) {
        for (uint256 i = 0; i < approbations.length; i++) {
            if (approbations[i] == false) {
                return false;
            }
        }
        return true;
    }
}
