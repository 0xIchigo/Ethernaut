# Coin Flip

The goal of this level is to correctly guess the outcome of a coin flip 10 times in a row. The number of `consecutiveWins` is initialized as 0 within the `constructor()`. If a wrong guess is passed at any point, the `consecutiveWins` is reset to 0.

The issue with this contract is that Ethereum is a deterministic Turing machine, meaning there is no inherent randomness on the EVM. Developers mistakenly use data related to blocks, such as `block.number`, or `block.timestamp`, to "achieve" randomness, however these values are not random and can be exploited. Here, `flip()` introduces what appears to be the start of randomness by calculating the blockhash:
```
uint256 blockValue = uint256(blockhash(block.number - 1));
```
The `blockValue` is then divided by `FACTOR` which is used to determine `coinFlip` - the coin flip result. `FACTOR` is the third state variable, which is equal to 57896044618658097711785492504343953926634992332820282019728792003956564819968 - we know what factor the blockhash is being divided by every single guess as it is available to us, removing any credible randomness. A check is then made to see whether `coinFlip == 1`, returning `true` or `false`using Solidity's [ternary operator](https://www.geeksforgeeks.org/ternary-operators-in-solidity/):
```
bool side = coinFlip == 1 ? true : false;
```
Then, `_guess` is provided to `flip()` as a parameter. Within the function, the user `_guess` is checked against `side` to see whether the correct guess was provided. This is problematic as we are able to calculate the correct guess using the blockhash, `FACTOR`, and returning whether the division of the two is equal to 1. This is demonstrated in the `AttackCoinFlip.sol` contract provided in this folder.

In `AttackCoinFlip.sol` we calculate the correct guess using the logic directly from `CoinFlip.sol`:
```
function calculateGuess() private view returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;

        return coinFlip == 1;
}
```
And with `calculateGuess()`, we can return the correct guess every time in a separate external function:
```
function flip() external {
        bool correctGuess = calculateGuess();
        require(target.flip(correctGuess), "Guess failed");
}
```
In order to complete this level, simply call `flip()` 10 times.