# Fallback

The goal of this level is to claim ownership of Fallback.sol and reduce it's balance to zero. Ownership is required to pass the `onlyOwner` modifier on `withdraw()` which can be called to send the contract's entire balance to the owner's address.

There are two places that ownership is set: in the `constructor()` and in `receive()`. We want to look at the `receive()` function, since we cannot set the owner in the constructor. In order to claim ownership, we need to set at least 1 wei to the contract, which will trigger `receive()`:
```
  receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }
```
We also need to call `contribute()` with a contribution in order to satisfy the `contributions[msg.sender] > 0` check in the receive function's require statement:
```
function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if(contributions[msg.sender] > contributions[owner]) {
      owner = msg.sender;
    }
}
```
Thus, in order to claim ownership of the contract and drain it of its funds, we can do the following steps:
- Send >0.001 ether to the contract using `contribute()`
- Send 1 wei to the contract using a low-level call
- Call `withdraw()`
- Profit