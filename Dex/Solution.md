# Dex

The goal of this level is to hack the `DEX` contract and steal the funds by price manipulation. We start with 10 tokens of `token1` and 10 tokens of `token2`. The DEX contract starts with 100 of each token. The key to this level is already given to us: we must steal the funds by *price manipulation*. Let's look at `swap()` and `getSwapPrice()`.

The `swap()` function in the `Dex` contract performs a swap between `token1` and `token2` as follows:
```
function swap(address from, address to, uint amount) public {
    require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    uint swapAmount = getSwapPrice(from, to, amount);
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
}
```
We see that the `from` and `to` params must either be `token1` or `token2` - this function will not execute for any other type of token. From there we check that the user has enough tokens to execute the swap. Then, the `swapAmount` is calculated based on a call to `getSwapPrice()` where the `from`, `to`, and `amount` params are passed into the function call. After that, the function finishes by swapping the tokens using two `transferFrom` calls based on the approved amount.

The code for `getSwapPrice()` is fairly straightforward:
```
return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));
```
This swap price calcuation follows the constant funtion market maker equation `x * y = k`, which was popularized by Uniswap. The ratio `k` is initialized as 1 in our case as the DEX has equal amounts of `token1` and `token2`, making the pool ratio 1:1. This calculation ensures that every time the DEX pool diverges from `k` there is a price increase/decrease that seeks to return the pool ratio towards `k`. Now how can we manipulate this price calculation?

It is important to note that Solidity does not support decimals, only integer (whole) numbers. This means that when division occurs and the quotient is a fraction, the quotient is rounded down towards zero (e.g. 5 / 2 != 2.5 -> 5 / 2 = 2). Thus, the tokens used in this contract will return unexpected results in situations where precise division is required. We can abuse this by continually swapping our total balance of `token1` to `token2` and then `token2` to `token1` to exponentially grow our balance. This arithmetic faulure will allow us to withdraw all the tokens. The magic number here is 65 - once we hit 65 tokens of either `token1` or `token2`, we can drain the entire balance of the respective token:

| Dex    |        | User   |        |
|--------|--------|--------|--------|
| token1 | token2 | token1 | token2 |
|--------|--------|--------|--------|
| 100    | 100    | 10     | 10     |
| 110    | 90     | 0      | 20     |
| 86     | 110    | 24     | 0      | 
| 110    | 80     | 0      | 30     | 
| 69     | 110    | 41     | 0      |
| 110    | 45     | 0      | 65     |
| 0      | 90     | 110    | 20     |

To pass the level, deploy `AttackDex` from `AttackDex.sol` passing in the instance address to the `constructor()` as the target address. We need to deploy the IERC20 interface at both the address of token1 and token2, as well as the IDEX interface at the instance address, so we can approve `AttackDex` for the hack contract. Deploy IDEX first so you can get the addresses for `token1` and `token2`. Then deploy each token at their respective address, approving the address for `AttackDex` for a large amount such as 1000 or 100000. Then call the `hack()` function in `AttackDex` which swaps the tokens until we drain the entire balance of `token1` from the DEX, based on the math above.