// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "src/Desplit.sol";
import "src/ERC20Mock.sol";

contract DesplitTest is Test {
    // the contract constructor is called again before each test
    // so the following variable reset
    Desplit desplit = new Desplit();
    DesplitGroup group;
    // addresses in the group:
    address add1 = address(1);
    address add2 = address(2);
    address add3 = address(3);
    // outside the group:
    address recipient = address(4);
    ERC20Mock token;

    function setUp() public {
        // this function is called before each test
        address[] memory addresses = new address[](3);
        addresses[0] = add1;
        addresses[1] = add2;
        addresses[2] = add3;

        desplit.createGroup(addresses);
        group = desplit.groups(0);
        token = new ERC20Mock("ETH", "truc", address(20), 113);
        token.mint(add1, 10000);
    }

    function testOneGroup() public {
        assertTrue(desplit.groupCount() == 1);
    }

    function testLogAddresses() public logs_gas {
        console2.log("GROUP:", add1, add2, add3);
        console2.log("CONTRACT", address(this));
    }

    function testCreatePayment() public {
        vm.prank(add1); // msg sender become add1, so add1 is making the following request:
        group.createPaymentRequest(token, recipient, 12);
        ( 
            address _sender,
            address _recipient,
            uint256 _amount,
            Approbations _approbations,
            IERC20 _token
        ) = group.payments(0);
        
        assertTrue(_sender == add1 );
        assertTrue( _recipient == recipient );
        assertTrue( _amount == 12 );
        assertTrue(_approbations.list(0) == true );
        assertTrue(_approbations.list(1) == false );
        assertTrue(_approbations.list(2) == false );

        vm.prank(add2);
        group.validate(0, true);
        assertTrue(_approbations.list(1) == true );


        assertTrue( _token == token );
    }



    function testPayment() public {
        token.approveInternal(add1, address(group), 57);
        group.transferDesplit(add1, recipient, token, 10);
    }

}
