# Vault

The goal of this level is to unlock the vault to pass the level. To unlock the vault, we must call `unlock()` which takes a `bytes32 _password` paramater. If the `_password` matches the `password` set in the `constructor()` then the vault will be unlocked with `locked = false`. It is vital to note that *all data on the blockchain is public.* Just because a variable's visibility is set to private does not mean that the data itself is private as anyone can view this data.

For this challenge we need to read the value of the `password` from its storage slot. The EVM stores data in slots, which are 32 bytes in size. Slot packing occurs to optimize storage when more than one variable can fit into a slot. For this challenge, we need to read the data at storage slot 1 and pass that into `unlock()` as the password.

There are a few ways you can read this contract's storage slots. For example, you can use [cast](https://book.getfoundry.sh/cast/)