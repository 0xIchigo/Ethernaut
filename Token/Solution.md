# Token

The goal of this level is to obtain more than the initial 20 tokens that are given to you, preferably a very large amount of tokens. The exchange of tokens is found in the `transfer()` function:
```
function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
}
```
At first glance, the contract seems pretty good given the require statement makes sure the `msg.sender`'s balance never goes below zero. The issue, however, is in the following line when the value is deducted from the balance using the subtraction assignment operator. 

## Overflows and Underflows

As an aside, all variables in Solidity have a maximum capacity that they can store. The number of bits determines the range of values that can be stored in that variable. With the example of `uint256`, the largest number that can be stored is `2^256 - 1`, which works out to be `115792089237316195423570985008687907853269984665640564039457584007913129639935`. So, a `uint256` can store any number from 0 to `2^256 - 1`. 

Let's use a shorter example: the largest number a `uint8` can store is `2^8 - 1`, which is `255` (binary 11111111). Thus, a `uint8` can store numbers from `0` to `255`. An overflow is when the variable reaches their maximum capacity (byte size) and resets back to its inital minimum point, which is 0, because it can't hold any more numbers. Here, when you add `1` to binary 11111111, it resents back to 00000000. An underflow is when the variable is already at its minimum capacity, and cannot store any smaller numbers so it wraps back around to its maximum size. Here, when you subtract `1` from binary 00000000 you get 11111111.

In summary: if you subtract `1` from a `uint8` that is equal to 0, you'll get `255`. If you add `1` to a `uint8` that is equal to 255, you'll get `0`.

## The Vulnerability
In older versions of Solidity, there is no validation for overflows and underflows forcing developers to implement their own checks. This is why libraries such as OpenZeppelin's [SafeMath library](https://docs.openzeppelin.com/contracts/2.x/api/math) were developed to have checked arithmetic. Since Solidity 0.8.0 and onwards, there is no need to use such librariues as the compiler natively checks for overflows and underflows, reverting if detected. The issue with this contract is that it is using version `^0.6.0` and does *not* use any library, or implement custom checks, for overflows or underflows. 

Therefore, we can underflow `balances[msg.sender]` with the line `balances[msg.sender] -= _value;` to get the largest number a `uint256` can store, which is `2^256 - 1`. To hack the level simply call `transfer()` with a value of 21 since we have 20 tokens initially. This is done in `AttackToken.sol`. Instead of providing `msg.sender` as the `_to` param in `transfer()`, you can also provide a random address.