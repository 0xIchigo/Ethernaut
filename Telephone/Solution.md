# Telephone

This objective of this level is to claim ownership of the contract, which is fairly straightforward. Ownership is set in two places: in the `constructor()` and `changeOwner()`. Since we cannot set the `owner` in the constructor, we want to focus on `changeOwner()`:
```
function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
}
```
The function checks whether `tx.origin`, is not equal to `msg.sender`. To exploit this contract, we need to know the difference betwen `tx.origin` and `msg.sender`: `tx.origin` refers to the original external account that started the transaction while `msg.sender` refers to the immediate account, which can be an EOA or a contract, that invokes the function. With `msg.sender` the owner can be a contract but with `tx.origin` the owner can never be a contract.

If an EOA calls contract A, both the `msg.sender` and `tx.origin` would be equal to the address of the EOA. If contract A makes a call to contract B, however, then the `msg.sender` would be equal to the address of contract A and the `tx.origin` would be equal to the address of the EOA. 

Thus, in order to claim ownership of the contract and satisfy the if statement, we need to make sure that our `msg.sender` and `tx.origin` are not equivalent. This can be done by using an intermediart contract which makes a call to Ethernaut's contract. In `AttackTelephone.sol`, we create a hack contract that calls `changeOwner()` from `Telephone.sol` in its constructor, so we don't have to make any separate calls.