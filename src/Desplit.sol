//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "forge-std/console2.sol";


function logInt(int i) view {
    if(i<0){
        console2.log("-", uint(-i));
    }
    else{
        console2.log(uint(i));
    }
}
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
    Payment[] public payments;
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
        IERC20 token,
        address recipient,
        uint256 amount
    ) public returns (uint) {
        payments.push(
            Payment(
                msg.sender,
                recipient,
                amount,
                new Approbations(addresses.length),
                token
            )
        );
        uint paymentIndex = payments.length - 1;
        validate(paymentIndex, true); // sender is validating by default
        return paymentIndex;
    }

    function transferDesplit(address sender, address recipient, IERC20 token, uint amount) public {
        token.transferFrom(sender, recipient, amount);
        uint n = addresses.length;
        for (uint i = 0; i < n; i++) {
            if (addresses[i] != sender) {
                console2.log("balance of:", addresses[i], "result:");
                logInt(balances[addresses[i]]);
                balances[addresses[i]] -= int(amount / n);
                console2.log("modifying balance of:", addresses[i], "result:");
                logInt(balances[addresses[i]]);
            }
        }
        balances[sender] += int((n-1) * (amount / n));

        console2.log("transfer done, balance sender:"); 
        /* console2.logInt(balances[sender]); */
        logInt(balances[sender]);
        console2.log("balances addr1:");
        logInt(balances[addresses[1]]);
        // TODO how to send notifications
    }


    function validate(uint pIndex, bool b) public {
        console2.log("validation du payment par: ", msg.sender);

        for (uint256 i = 0; i < addresses.length; i++) {
            if (msg.sender == addresses[i]) {
                payments[pIndex].approbations.approve(i, b);
            }
        }
        // check that everyone approved the transaction
        if (payments[pIndex].approbations.allApproved()) {
            transferDesplit(
                payments[pIndex].sender,
                payments[pIndex].recipient,
                payments[pIndex].token,
                payments[pIndex].amount
            );
        }
    }
}

struct Payment {
    address sender;
    address recipient;
    uint256 amount;
    Approbations approbations;
    IERC20 token;
}

contract Approbations{
    bool[] public list;

    constructor(uint256 size) {
        list = new bool[](size);
    }

    function approve(uint256 i, bool b) public {
        // restreindre les droits à ceux qui sont dans le groupe
        // empêcher à la i eme personne d'approuver pour la i+1
        list[i] = b;
    }

    function allApproved() public view returns (bool) {
    for (uint256 i = 0; i < list.length; i++) {
        if (list[i] == false) {
            return false;
        }
    }
    return true;
}
}
