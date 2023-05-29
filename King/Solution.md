# King

The goal of this level is to break the game. The game is called King and to play users have to send Ether to the contract. Whoever sends an amount of Ether that is larger than the current prize becomes the new king. On such an event, the overthrown king gets paid the new prize, making a bit of Ether in the process. The issue with this design is that it is open to DOS (denial of service) attacks as the contract is sending Ether to the overthrown king. What happens if the king cannot accept the Ether?

# The Vulnerability
The vulnerability lies in the `receive()` function: 
```
receive() external payable {
    require(msg.value >= prize || msg.sender == owner);
    payable(king).transfer(msg.value);
    king = msg.sender;
    prize = msg.value;
}
```
The `receive()` function first checks that the `msg.value` is larder than the current prize, or if the `msg.sender` is the owner of the contract. Once that is satisfied, the function then tries to send the `msg.value` to the overthrown `king`.  To hack this contract, we can make our own contract that sends enough Ether to become the king. We could make a `fallback()` or `receive()` function with a `revert()` statement but why go through the extra trouble when we don't have to include a `fallback()` or `receive()` function? In `AttackKing.sol` we create the contract `AttackKing`, which we deploy with the `prize` amount as the `msg.value`. We do not implement any functionality to receive Ether, therefore hacking the contract and passing the level.