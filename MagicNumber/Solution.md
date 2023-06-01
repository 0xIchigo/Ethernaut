# MagicNumber

The goal of this level is to provide a `solver` (a contract) that responds to `whatIsTheMeaningOfLife()` with the right number. The catch is that the solver's code needs to be at most 10 opcodes. The magic number that we need to pass in is 42, a reference to the Hitchhiker's Guide to the Galaxy. Ideally, we could write a contract such as this:
```
contract Solve {
    function whatIsTheMeaningOfLife() external pure returns (uint) {
        return 42;
    }
}
```
The issue with this code is that it'll be longer than 10 opcodes. So now what?

## Building a Contract With Opcodes

We'll being by making our `SolveConctract` contract in `SolveContract.sol` with a `constructor()` that takes in a `target` address. We'll also create `IMagicNum`, an interface for `MagicNumber` contracts with the functions `solver()` and `setSolver()`. We'll also need an `ISolver` interface with the `whatIsTheMeaningOfLife()` function. Back to the `constructor()`, we'll make `target` of type `IMagicNumber`. Funnily enough, Solidity by Example contains an example of a [simple bytecode contract](https://solidity-by-example.org/app/simple-bytecode-contract/) which happens to return the number 42. 

We can use the bytecode `hex"69602a60005260206000f3600052600a6016f3"` in our contract. Copy-pasting can easily get the job done but we should also understand what's going on under the hood. For our runtime opcodes, we need to do the following:
- Push and store 42 (0x2a) in memory
    PUSH1 0x2a
    PUSH1 0
    MSTORE
- Return 32 bytes from memory
    PUSH1 0x20
    PUSH1 0
    RETURN

Here, `mstore(p, v)` stores v at mempory p to p + 32 and `return(p, s)` ends execution and returns the data from memory p to p + s. This is our runtime code. 

For the creation code, we want to do the following:
- Store the runtime code to memory
    PUSH10 0x602a60005260206000f3
    PUSH1 0
    MSTORE
- Return to bytes from memory starting at offset 22 as our 10 bytes are padded with zeros to the left 
    PUSH1 0x0a
    PUSH1 0x16
    RETURN

Now we can use Yul to manually deploy the contract. Within the constructor, we can create an `assembly` block using `create(value, offset, size)`. `value` represents the amount of Ether we'll be sending this contract, which in our case is 0. `offset` refers to the pointer in memory where the code is stored. We can use `bytecode`, skipping the first 32 bytes as the code is stored in a dynamic array and the first 32 bytes stores the length of the array, or in our case the length of the bytecode. We can add 32 bytes to this pointer, which in hexadecimal is 0x20. To determine `size` we can take the length of `bytecode`, which is 38 characters. Since every 2 characters represents 1 byte, we get 19 as the size of our bytecode. In hexadecimal, 19 is represented as 0x13. We can assign `create()` to `address addr` as such:
```
addr := create(0, add(bytecode, 0x20), 0x13)
```
The beauty of this contract is that it is exactly 10 opcodes. The runtime code we get is 602a60005260206000f3. This is 20 characters long, which converted to bytes is 10 bytes. To pass the level, deploy `SolveContract` with the instance address of `MagicNumber` as the `target` address.