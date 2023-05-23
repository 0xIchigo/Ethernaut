# Fallout

The goal of this level is to claim ownership of `Fallout.sol`. The only place this contract sets the owner is within its constructor. Prior to [Solidity 0.4.22](https://blog.soliditylang.org/2018/04/17/solidity-0.4.22-release-announcement/), constructors were defined as functions that carried the same name as the contract. So the constructor for contract `HelloWorld` would be `HelloWorld()`.

The issue with this naming convention is that it is prone to human error - developers can accidentally misspell the constructor name, or forget to update it when contracts are renamed. Take a closer look at `Fallout.sol`'s constructor function:
```
function Fal1out() public payable {
        owner = msg.sender;
        allocations[owner] = msg.value;
}
```
The name of the constructor is misspelled, which means that it is just another function with a `public` visibility. This means that any external user or function inside the contract can call this function. Thus, whoever calls `Fal1out()` becomes the owner of the contract.

## Remix Users
If you are trying to complete these levels within Remix, you can't always copy/paste the contract code and deploy it as is. If you try copy-pasting you'll be met with the following error: `Error: not found openzeppelin-contracts-06/math/SafeMath.sol`. An easy way to circumvent this would be to code a contract like so:
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Fallout {
    function Fal1out() external payable;
}
```
Here, you can deploy the contract at the provided address and call `Fal1out()` in order to complete the level.