# Gatekeeper Two

The goal of this level is the same as the last gatekeeper: make it past the gatekeeper and register as an entrant. To register, we must call the `enter()` function, which contains three modifiers.

The `gateOne` modifier checks that the `msg.sender != tx.origin`. Again, this means that we must use a contract to interact with `GatekeeperTwo` as the `msg.sender` will be that of our attack contract (`AttackGatekeeperTwo.sol`) and not our wallet address.

The `gateTwo` modifier executes some *assembly* code using the opcode `extcodesize`. Within Solidity, you can write Inline Assembly (also known as Yul) as follows: `assembly { ... }`. Within that code block, the `extcodesize` opcode is used to check the size of code stored at an address. If it returns a number larger than zero, the address is a contract. Thus, we need to find a way to return a code size of 0 in order to pass this challenge. 

`extcodesize` is unreliable for checking whether an address is a contract, however, because when a contract's `constructor()` is called during its initialization, its runtime code size is 0. To pass the `gateTwo` modifier we need to call the `enter()` function inside of the `constructor()` of `AttackGatekeeperTwo.sol`.

The `gateThree` modifier has a number of calculations regarding the `_gateKey` parameter. We can solve what to pass in as the `_gateKey` by restructuring the XOR operation. Within the require we have that `uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max`. Here, let 
- `A = uint64(bytes8(keccak256(abi.encodePacked(msg.sender))))`
- `B = uint64(_gateKey)`
- `C = type(uint64).max`
We can express this modifier as A ^ B == C such that the XOR operation forms a commutative group. So, if `A ^ B == C` then `A ^ C == B`. If you're interested, the math behind it:
```
A ^ B = C
A ^ B ^ (B ^ C) = C ^ (B ^ C)
A ^ (B ^ B) ^ C = (C ^ C) ^ B
A ^ 0 ^ C = 0 ^ B
A ^ C = B
```
We can therefore rewrite the gate key as `uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max`. Remember to replace `msg.sender` with `address(this)` as we want to use the contract's address and not our own. To pass the gatekeeper, simply deploy the `AttackGatekeeperTwo` contract at the instance address. 