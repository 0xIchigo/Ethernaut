# Delegation

The goal of this level is to claim ownership of the given instance. The deployed contract is `Delegation`, which deploys `Delegate` and sets its owner in the `constructor()`. The only other function we can call is the `fallback()` function, which uses `delegatecall` to execute the code inside `Delegate`.

## Delegatecall
`delegatecall` is a low level function similar to call, however it executes the called contract's code within the context of the calling contract. Assume we have two contracts `A` and `B`. When contract `A` executes `delegatecall` to contract `B`, contract `B`'s code is executed with contract `A`'s storage, `msg.sender`, and `msg.value`. The rule of thumb with `delegatecall`s is to ensure that both contracts have the same storage layout as it is possible to modify a contract's storage using malicious code belonging to another contract. This is how we'll exploit the contracts to gain ownership of `Delegate`.

## The Vulnerability
The `Delegation` contract uses a `delegatecall` in its `fallback()`:
```
fallback() external {
    (bool result,) = address(delegate).delegatecall(msg.data);
    if (result) {
        this;
    }
}
```
Here, `Delegation` is making a `delegatecall` to `Delegate` taking the input of `msg.data`. We can control the `msg.data` passed since we are able to trigger the fallback function. This is interesting as `Delegate` contains this `pwn()` function:
```
function pwn() public {
    owner = msg.sender;
}
``` 
If we look at the storage slots, we see that the owner (`address public owner`) is set in slot 0 of both contracts. Thus, when we modify the `owner` in `Delegate` this will also modify the `owner` in `Delegation`.

Therefore, to hack this level we need to trigger `fallback()` in `Delegation` to invoke `pwn()` using `msg.data`. Executing `pwn()` will make our user the owner of the `Delegate` contract, as well as `Delegation` because of the storage layout and naming of both contracts. In Remix, simply deploy `Delegate` at the given instance and call `pwn()` with a higher gas estimate than provided (I ran into the issue of contract execution completing, despite having an out of gas error occur).