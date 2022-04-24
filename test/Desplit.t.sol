// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "src/Desplit.sol";


contract DesplitTest is Test {
    Desplit c;
    function setUp() public logs_gas {
        c = new Desplit();
        // console2.log(address(this));
        // emit log_address(address(this));
    }

    function testConsoleLog() public logs_gas {
        assertTrue(true);
    }
}
