// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMagicNum {
    function solver() external view returns (address);
    function setSolver(address) external;
}

interface ISolver {
    function whatIsTheMeaningOfLife() external view returns (uint256);
}

contract SolveContract {
    constructor(IMagicNum target) {
        bytes memory bytecode = hex"69602a60005260206000f3600052600a6016f3";
        address addr;

        assembly {
            addr := create(0, add(bytecode, 0x20), 0x13)
        }

        require(addr != address(0));
        target.setSolver(addr);
    }
}
