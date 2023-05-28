# Force

The goal of this level is to make the balance of the contract greater than zero. The interesting part about this contract is that it contains no code, only a commented out ASCII art of a cat. Therefore, there needs to be a way to *forcefully* send Ether to this contract.

There are three ways to forcefully send Ether to a contract:
- Smart contracts can receive Ether from other contracts as a result of a `selfdestruct()` call
- An attacker can pre-calculate a contract's address before it is generated and deposit funds into the address before deployment
- An attacker can use the contract's address as their block coinbase and rewards (Ether) will be sent that that address

The easiest way to forcefully send Ether to this contract would be to create a smart contract that uses `selfdestruct()` to forward its balance to the target contract. This is done in `AttackForce.sol` in the constructor function. So, we deploy `AttackForce` with a value of 1 wei and pass in the target address as a constructor parameter. Once that is done, we have completed the level by forcefully sending Ether to the given contract.

Note: `selfdestruct` is being deprecated ([EIP-4758](https://eips.ethereum.org/EIPS/eip-4758)) and I would not recommend using it going forward. EIP-4758 proposes to rename the `SELFDESTRUCT` opcode to `SENDALL` and making its new functionality to only send all Ether in the account to the caller.