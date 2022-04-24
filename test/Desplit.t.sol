// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "forge-std/console2.sol";
import "src/Desplit.sol";


contract DesplitTest is DSTest {
    Desplit c;
    function setUp() public {
        c = new Desplit();
    }

    function testConsoleLog() public {
        console2.log("test");
        assertTrue(true);
    }
}
