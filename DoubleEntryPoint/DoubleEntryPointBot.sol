// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IForta {
    function raiseAlert(address) external;
    function setDetectionBot(address) external;
}

interface IDetectionBot {
    function handleTransaction(address, bytes calldata) external;
}

contract DoubleEntryPointBot is IDetectionBot {
    address vault;

    constructor(address _vault) {
        vault = _vault;
    }

    function handleTransaction(address user, bytes calldata msgData) external {
        // We can access origSender by slicing into msgData
        (,, address origSender) = abi.decode(msgData[4:], (address, uint256, address));

        if (origSender == vault) {
            IForta(msg.sender).raiseAlert(user);
        }
    }
}
