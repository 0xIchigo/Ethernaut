# Gatekeeper Three

The goal of this level is to pass through all of the gates to become an entrant. To become an entrant, we must call `enter()` passing three modifiers.

The `gateOne` modifier checks that the `msg.sender` is the `owner` and `tx.origin` is not. To make ourselves the `owner` we can call the function `construct0r()`, a fake  constructor function with public visibility, which sets `owner` to `msg.sender`. In order to pass the second check, we need to send the transaction from a smart contract.

The `gateTwo` modifer checks that the correct password has been sent to the `SimpleTrick` contract via a `getAllowance()` call:
```
modifier gateTwo() {
    require(allowEntrance == true);
    _;
}

function getAllowance(uint256 _password) public {
    if (trick.checkPassword(_password)) {
        allowEntrance = true;
    }
}
```
In `getAllowance()`, the `SimpleTrick` contract's `checkPassword()` function is called to validate whether the call was made in the same block where `password` was set given `uint256 private password = block.timestamp`:
```
function checkPassword(uint256 _password) public returns (bool) {
    if (_password == password) {
        return true;
    }
    password = block.timestamp;
    return false;
}
```
To pass this gate, we must send our solution in one transaction which can be done by bundling all our actions into one function of our malicious contract.

The `gateThree` modifier checks that the contract has a balance greater than 0.001 Ether and the `owner` is unable to receive the balance:
```
modifier gateThree() {
    if (address(this).balance > 0.001 ether && payable(owner).send(0.001 ether) == false) {
        _;
    }
}
```
This can be passed easily by sending more than 0.001 Ether to our malicious contract during its deployment and not implementing any sort of `receive()` or `fallback()` functionality to accept Ether.

For some reason, I was getting a number of errors trying to use an interface. So, we are going to copy the two contracts in `GatekeeperThree.sol` and paste them at the top of our `AttackGatekeeperThree.sol` file. Next, we want to deploy `GatekeeperThree` at the instance address. Then, we want to deploy `AttackGatekeeperThree` passing in the address of the `GatekeeperThree` contract. When deploying `AttackGatekeeperThree` we also want to send a value of 1000000000000001 wei so we can pass the `address(this).balance > 0.001 ether` check. Then, call `hack()` to pass the level.
