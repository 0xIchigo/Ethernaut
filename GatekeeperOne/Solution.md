# Gatekeeper One

The goal of this contract is to make it past the gatekeeper and register as an entrant. To register, we must call the `enter()` function, which contains three modifiers.

The `gateOne` modifier checks that the `msg.sender != tx.origin`. This means that we must use a contract to interact with `GatekeeperOne` as the `msg.sender` will be that of our attack contract (`AttackGatekeeperOne.sol`) and not our wallet address.

The `gateTwo` modifier checks that the `gasleft() % 8191 == 0`. This means that the `gasleft()` must be a multiple of 8191. We'll come back to this later.

The `gateThree`modifier has a number of checks regarding the `_gateKey` parameter. We can solve what to pass in as the `_gateKey` by rewriting the require statements as properties of the key. 

Let `x = uint64(_gateKey)` where:
```
uint32(x) == uint16(x)
uint32(x) != x
uint32(x) == uint16(uint160(tx.origin))
```
Here, we need to use upcasting, downcasting, and bitmasking to discern the correct `_gateKey`. We should start with the most restrictive requirement: `uint32(x) == uint16(uint160(tx.origin))`. In the `hack()` function in `AttackGatekeeperOne`, we use the variable k: `uint16 k = uint16(uint160(tx.origin));` This satisfies both `uint32(x) == uint16(x)` and `uint32(x) == uint16(uint160(tx.origin))` as k is a `uint16`. For the final condition `uint32(x) != x`, we can achieve this by bit shifting.

Bit shifting is an operation that involves moving the bits of a binary number to the left or right. This is useful insofar manipulating binary data; in our case it is useful for converting between different data types. Remember that `x = uint64(_gateKey)`. To make sure that the `uint32` and `uint64` types are not equivalent, we can place a 1 at the far left of x so when it gets casted to a `uint32` the 1 will be truncated in the type conversion such that `uint32(x) != x`. We can achieve this with the following: `uint64 newK = uint64(1 << 63) + uint64(k);` We can convert `newK` to a `bytes8` to use as our key.

Going back to the `gateTwo` modifier, we need to figure out the exact amount of gas we need to forward. There are two ways to go about this: using a debugger and counting the gas needed before the `gasLeft()` call is made, or bruteforcing the function. I went with the latter. Unfortunately, I ran into a number of Git issues adding Foundry to this repository, so I opted to include the Foundry test file however it does not run properly since Foundry is not installed. Within `AttackGatekeeperOne.test.sol` however, I implemented a `test()` function to determine the amount of gas needed:
```
function test() public {
    for (uint256 i = 100; i < 8191; i++) {
        try attack.enter(address(target), i) {
            console.log("Gas: ", i);
            return;
        } catch {}
    }
    revert("All tests have failed");
}
```
This works by calling the `enter()` function on our attack contract with the contract level's address. We also call `enter()` with i as the amount of gas.

The reason I went with the bruteforce method is because it is both more fun and easier. It is easier since we can express the total amount of gas we need to send as `x + (8191 * y)` where x is the amount of gas used before `gasLeft()` was called and y is some constant where the parentheses evaluate to a multiple of 8191. If we set `y = 10`, for example, we can then bruteforce for x.

The line `require(target.enter{gas: 8191 * 10 + gas}(gateKey), "Unable to enter");` discerns the amount of gas needed as once that `require()` check passes, we return to the `test()` call and console.log the amount of gas. In our case, we needed to pass 256 gas for it to succeed. To complete the level, simply deploy the `Attack` contract found in `AttackGatekeeperOne`. Then call the `enter()` function passing in the instance address and amount of gas found by your `test()` function. 