//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "forge-std/console2.sol";

// main contract storing all the groups
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

// contract to manage one particular group
contract DesplitGroup {
    address public creator;
    address[] public addresses;
    Request public request;
    // TODO we need a list of txs
    mapping(address => int256) public balances;

    constructor(address _creator, address[] memory _addresses) {
        creator = _creator;
        addresses = _addresses;
/*         console2.log("THIS IS A TEST !!!!!!!", 17); */
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

    function transferDesplit(address sender, address recipient, IERC20 token, uint amount) public {
        token.transferFrom(sender, recipient, amount);
        uint n = addresses.length;
        for (uint i = 0; i < n; i++) {
            if (addresses[i] != sender) {
                console2.log("balance of:", addresses[i], "result:", uint(balances[addresses[i]]));
                balances[addresses[i]] -= int(amount / n);
                console2.log("modifying balance of:", addresses[i], "result:", uint(balances[addresses[i]]));
            }
        }
        balances[sender] += int((n-1) * (amount / n));

        console2.log("transfer done, balance sender:"); 
        /* console2.logInt(balances[sender]); */
        console2.log(uint(balances[sender]));
        console2.log("balances addr1:", uint(balances[addresses[1]]));
        // TODO how to send notifications
    }


    function validate(bool b) public {
        for (uint256 i = 0; i < addresses.length; i++) {
            if (msg.sender == addresses[i]) {
                request.approbations.approve(i, b);
            }
        }
        // check that everyone approved the transaction
        if (request.approbations.allApproved()) {
            transferDesplit(
                request.sender,
                request.recipient,
                request.token,
                request.amount
            );
        }
    }
}

struct Request {
    address sender;
    address recipient;
    uint256 amount;
    Approbations approbations;
    IERC20 token;
}

contract Approbations {
    bool[] public approbations;

    constructor(uint256 size) {
        approbations = new bool[](size);
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
