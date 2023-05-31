# Naught Coin

The goal of this level is to get our token balance to 0. `NaughtCoin` mints us the entire supply of its coin contingent upon the fact that we cannot transfer the tokens until a 10 year lockout period passes. This is achieved with the `lockTokens()` modifier:
```
modifier lockTokens() {
    if (msg.sender == player) {
        require(block.timestamp > timeLock);
        _;
    } else {
         _;
    }
}
```
This modifier checks that the `msg.sender` is not equal to the `player` - our address. Thus, while we are not allowed to interact with the `transfer()` function, other EOAs or contracts can passing the `lockTokens()` modifier. The trick to this level is that Naught Coin is an ERC20 token.

## ERC20 Tokens
ERC20 tokens follow the [ERC-20 Token Standard](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/), a token standard that implements an API for tokens within smart contracts. The fact that Naught Coin is an ERC20 token is important is that it contains certain methods such as:
```
function approve(address _spender, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
```
The `approve()` function is useful insofar you can approve other EOAs and *contracts* to spend a set number of tokens on your behalf. The `transferFrom()` function is useful insofar you can transfer tokens from any one address to another. Coupled with the `approve()` function, we could approve a smart contract to spend all of our Naught Coin and then have that smart contract transfer the tokens out of our wallet, using the `transferFrom()` function. This would satisfy the `lockTokens()` modifier and would result in us having a balance of zero. 

## Hacking the Level
To pass this level, deploy `AttackNaughtCoin`. After, deploy the IERC20 interface at the Naught Coin address and call the `approve()` function approving the total supply of Naught Coin. Then call the `remove()` function to transfer the Naught Coin out of our wallet. 