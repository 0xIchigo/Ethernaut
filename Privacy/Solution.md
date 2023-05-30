# Pirvacy

The goal of this level is to unlock the contract. To unlock the contract, we must call `unlock()` with the correct `bytes16 _key`. The key is equivalent to the `bytes32` stored in the second index of the `bytes32` array `data` casted to `bytes16.` 

It is vital to note, as mentioned in the Vault level solution, that *all data on the blockchain is public.* Just because the bytes32 array that stores the data is marked as private does not mean we cannot read this data. For this level, we need to understand slot packing. Remember from the Vault level solution that slot packing occurs to optimize storage when more than one variable can fit into a slot. Therefore, we must look at the size of each state variable to determine which slot it fits into:
```
bool public locked = true; // Slot 0
uint256 public ID = block.timestamp; // Slot 1
uint8 private flattening = 10; // Slot 2
uint8 private denomination = 255; // Slot 2
uint16 private awkwardness = uint16(block.timestamp); // Slot 2
bytes32[3] private data; // Slots 3 to 6
```
This is the following breakdown:
- `bool locked` fits into slot 0 as it only takes up 8 bits, or 1 byte of space
- `uint ID` fits into its own full slot, slot 1, as it takes up 32 bytes or 256 bits of space
- `uint8 flattening` fits into slot 2 as it only takes up 1 byte of space and slot 1 is full
- `uint8 denomination` fits into slot 2 as it only takes up 1 byte of space and can be packed next to `flattening`
- `uint16 awkwardness` fits into slot 2 as it only takes up 2 bytes of space and can be packed next to `flattening` and `denomination`
- `bytes32[3] data` fits into slots 3 to 6. Array data always starts in a new slot and occupies the full slot

According to this breakdown, we can determine that `_key`, i.e. `data[2]`, is in slot 5. To clear the level, we need to pass in the value of `data[2]` as `bytes16` as a parameter of `unlock()`. Again, we can use a tool such as Cast to read the variable, or, since we know the slot, use the console: `await web3.eth.getStorageAt(instance address, 5);` This returns: `0x4b701486fcf3305260b5eb9fb7be5e3ae6b2dc84b1124d5bfa707cd6d159a2da`, which cast to `bytes16` is the `_key`. Using the console, this can be done via:
```
data = "0x4b701486fcf3305260b5eb9fb7be5e3ae6b2dc84b1124d5bfa707cd6d159a2da";
key = data.slice(0, 34);
contract.unlock(key);
```