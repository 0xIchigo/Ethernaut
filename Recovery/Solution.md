# Recovery

The goal of this level is to recover, or remove, the 0.001 Ether from the lost contract address. Thus, we need to find the contract address and then recover the 0.001 Ether.

The latter should be simple enough as there is a `destroy()` function which calls `selfdestruct`. We can call this `destroy()` function passing in our wallet address as the `_to` parameter in order to recover the 0.001 Ether. Now we need to find the contract address.

`Recovery` is a factory contract that deploys a `SimpleToken` contract. Ether is sent to the `SimpleToken` contract via the `receive()` function. There are two ways to find the contract address:
- We can go onto Etherscan and look at all the txts that have called `generateToken()` in the `Recovery` contract, that way we can find the newly created `SimpleToken` contract.
- We can compute the contract's address using a specific formula, which is what we'll be doing

## Computing a Contract's Address

From [Stack Exchange](https://ethereum.stackexchange.com/questions/760/how-is-the-address-of-an-ethereum-contract-computed): "The address for an Ethereum contract is deterministically computed from the address of its creator (`sender`) and how many transactions the creator has sent (`nonce`). The `sender` and the `nonce` are RLP encoded and then hashed with Keccack-256. In Solidity:
```
nonce0 = address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, bytes1(0x80))))));
nonce1 = address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, bytes1(0x01))))));
```
My guess is that we'd want to use the `nonce1` computation as it is likely that nonce 1 was used when `generateToken()` was called. To find the contract address, we can deploy `RecoveryAddressComputation` and call `recover()` passing in the factory contract address (the instance address). Using the [Sepolia Testnet Explorer (Etherscan)](https://sepolia.etherscan.io/), we can verify that the address returned is a contract with with a balance of 0.001 ETH. 

## Passing the Level
Now with the lost contract address we can finish the level. First, we need to deploy the `SimpleToken` contract at the address returned from `recover()`. Once deployed, call the `destroy()` function with your account address as the parameter recovering the 0.001 Ether.