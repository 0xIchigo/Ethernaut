# Gatekeeper One

The goal of this contract is to make it past the gatekeeper and register as an entrant. To register, we must call the `enter()` function, which contains three modifiers.

The `gateOne` modifier checks that the `msg.sender != tx.origin`. This means that we must use a contract to interact with `GatekeeperOne` as the `msg.sender` will be that of our attack contract (`AttackGatekeeperOne.sol`) and not our wallet address.

The `gateTwo` modifier checks that the `gasleft() % 8191 == 0`. This means that the `gasleft()` must be a multiple of 8191. We'll come back to this later.

The `gateThree`modifier has a number of checks regarding the `_gateKey` parameter. We can solve what to pass in as the `_gateKey` by rewriting the require statements as properties of the key. 

Let `x = _gateKey` where:
```
uint32(x) == uint16(x)
uint32(x) != x
uint32(x) == uint16(uint160(tx.origin))
```
Here, we need to use upcasting, downcasting, and bitmasking to discern the correct `_gateKey`. We should start with the most restrictive requirement: `uint32(x) == uint16(uint160(tx.origin))`. In the `hack()` function in `AttackGatekeeperOne`, we use the variable k: `uint16 k = uint16(uint160(tx.origin));` This satisfies both `uint32(x) == uint16(x)` and `uint32(x) == uint16(uint160(tx.origin))` as k is a `uint16`. For the final condition `uint32(x) != x`
