// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "src/Desplit.sol";
import "src/ERC20Mock.sol";

contract DesplitTest is Test {
    Desplit desplit = new Desplit();
    address add1 = address(1);
    address add2 = address(2);
    address add3 = address(3);
    address add4 = address(4);

    function setUp() public {
        address[] memory addresses = new address[](3);
        addresses[0] = add1;
        addresses[1] = add2;
        addresses[2] = add3;
        desplit.createGroup(addresses);
        // emit log_address(address(this));
    }

    function testOneGroup() public {
        assertTrue(desplit.groupCount() == 1);
    }

    function testOneGroupAGAIN() public {
        assertTrue(desplit.groupCount() == 1);
    }

    function testLogAddresses() public logs_gas {
        console2.log("GROUP:", add1, add2, add3);
        console2.log("CONTRACT", address(this));
    }

    function testPayment() public {
        ERC20Mock token = new ERC20Mock("ETH", "truc", address(20), 113);
        token.mint(add1, 10000);
        DesplitGroup group = desplit.groups(0);
        token.approveInternal(add1, address(group), 57);
        group.transferDesplit(add1, add4, token, 10);
    }

}
