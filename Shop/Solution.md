# Shop

The goal of this level is to purchase the itme from the shop for less than the price asked. The `buy()` function checks whether the `_buyer.price()` is greater than or equal to the asking price, as well as whether the product has already sold:
```
function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
        isSold = true;
        price = _buyer.price();
    }
}
```
This means that we have to deploy an attack contract with a `price()` function that returns a `uint` price. The issue with this is that `isSold` is set to `true` before we return the `_buyer.price()` as `price`. Moreover, `price()` is a *view* function - we cannot modify state but we can read state. Thus, we can return two different values in our `price()` function depending upon the value of `isSold`. 

To pass this level, simply deploy `AttackShop` from `AttackShop.sol`, passing in the instance address to the `constructor()` so we can use it to check the `isSold` variable. Then, call the `hack()` function to start a `buy()` call. Here, we set the `price` way below the asking price of 100 at 1. It is important to remember that contracts can manipulate data seen by other contracts in any way they want. It is therefore unsafe to change the state based off of external and untrusted contracts logic