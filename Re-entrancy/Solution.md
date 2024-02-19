# Re-entrancy

The goal of this level is to steal all the funds from the contract `Reentrance`. The only way to send Ether in this contract is through the `withdraw()` function:
```
function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result,) = msg.sender.call{value:_amount}("");
      if(result) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
}
```
First, the contract checks whether the amount is less than or equal to the user's balance. A user's balance is kept track of in a mapping `balances` which updates according to the `msg.value` provided in a `donate()` function call. Then, the contract makes an external call to the `msg.sender`'s address. After the external call is made, the function updates the `msg.sender`'s balance in the `balances` mapping. This is a huge red flag as it violates the Checks-Effects-Interactions Pattern making the function vulnerable to reentrancy attacks.

## Checks-Effects-Interactions Pattern
A common security consideration is whether a function's execution follows the Checks-Effects-Interactions Pattern. This pattern holds that most functions perform checks, such as who called the function, whether arguments are in range, etc. These checks should occur first.

After, if all checks are passed, effects top the state variables of the current contract should be made.

Then, as a final step, all interactions with other contracts and EOAs should occur as the last step in any function. 

## Reentrancy
A reentrancy attack occurs when a contract makes an external call to another untrusted contract. Then, this untrusted contract makes a recursive call back to the original contract before the initial interaction is completed. There are different types of reentrancy attacks such as: single-function, cross-function, cross-contract, cross-chain, and read-only.

If the original contract changes state after an external call, the attacker can continually call the contract before these state variables are updated. Thus, if funds are transferred before a user's balance is updated in a withdraw function, for instance, an attacker could recursively call back into the contract once they have received the funds and initiate another withdrawal based on their previous balance. The attacker can continuously call the withdraw function to drain the contract's funds. 

## The Vulnerability
The `withdraw()` function does not follow the Checks-Effects-Interactions Pattern and is therefore vulnerable to a reentrancy attack. To hack the contract, we can do the following:
- Call `donate()` with some Ether to create a balance in our contract's account
- Create a `receive()` or `fallback()` function in our contract that calls into `withdraw()`, so when we receive Ether we reenter the contract with another call to `withdraw()`. We can implement a check to call `withdraw()` only if the contract still has any funds
- Have the contract `selfdestruct` sending all funds to our wallet

This is the flow of the `AttackReentrance` contract in `AttackReentrance.sol`.
