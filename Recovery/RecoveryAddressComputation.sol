// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RecoveryAddressComputation {
    function recover(address sender) external pure returns (address) {
        address addr =
            address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), sender, bytes1(0x01))))));

        return addr;
    }
}
