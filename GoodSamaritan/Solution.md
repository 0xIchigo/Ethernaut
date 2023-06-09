# Good Samaritan

The goal of this level is to drain all the balance from this wallet. The `Wallet` contract contains two custom errors, `OnlyOwner()` and `NotEnoughBalance()`. The latter is interesting as the `donate10()` function checks whether the balance of the wallet has less than 10 coins. If it does, then it reverts with the `NotEnoughBalance()` custom error. If it has more than 10 coins, the wallet donates 10 coins to the address provided:
```
function donate10(address dest_) external onlyOwner {
    // check balance left
    if (coin.balances(address(this)) < 10) {
        revert NotEnoughBalance();
    } else {
        // donate 10 coins
        coin.transfer(dest_, 10);
    }
}
```
The `onlyOwner` modifier, in this case, refers to the `GoodSamaritan` contract as it instantiates both a new `Wallet` and `Coin` in its `constructor()`:
```
constructor() {
    wallet = new Wallet();
    coin = new Coin(address(wallet));

    wallet.setCoin(coin);
}
```
In its `constructor()`, the `Coin` contract adds 1 million coins to the balance of `GoodSamaritan`. The `transfer()` function makes an interesting check whether the destination address is a contract, and if it is then it notifies the contract. Since we control the destination address provided, we can control the flow of execution after our contract is notified via `INotifyable(dest_).notify(amount_);` is called. The `requestDonation()` function within the `GoodSamaritan` contract is of importance as we can call it externally, and the functionality occurs inside a try-catch block. The `try` calls the `wallet.donate10(msg.sender)` where the `msg.sender` is the person who called the function. The `catch` block checks whether the error thrown as a result of the `try` is equivalent to the custom error `NotEnoughBalance()`. If the error matches then the wallet transfers the amount to the remaining amount to the `msg.sender` - we can send the remaining amount to ourselves thus draining the wallet.

To pass this level, simply deploy `AttackGoodSamaritan` from `AttackGoodSamaritan.sol`, passing in the instance address to the `constructor()`. We'll need both a `GoodSamaritan` and `Coin` interface so we can set them within the `constructor()`, and also validate our coin balance after the hack. Our `AttackGoodSamaritan` contract will need a `notify()` function with a `uint256 amount` parameter where we check if the amount is equal to 10. If it is then we'll revert with the custom error `NotEnoughBalance()`. To complete the hack, call the `hack()` function, which calls `requestDonation()` on the `GoodSamaritan` contract initiating the aforementioned logic.