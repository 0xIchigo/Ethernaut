# DoubleEntryPoint

The goal of this level is to discover the bug in `CryptoVault` and protect it from being drained out of tokens. Essentially, we have to register a Forta detection bot to prevent the bug. The only place that tokens can be transferred out of `CryptoVault` is at `sweepToken()`:
```
function sweepToken(IERC20 token) public {
    require(token != underlying, "Can't transfer underlying token");
    token.transfer(sweptTokensRecipient, token.balanceOf(address(this)));
}
``` 
The issue with this function is that if we pass `LegacyToken` into `sweepToken`, we drain DET instead of LGT. This occurs in `LegacyToken`'s `transfer()` imeplemtation as it contains the line: `return delegate.delegateTransfer(to, value, msg.sender);`. Here, `CryptoVault` calls `LegacyToken` making `msg.sender` the vault. This results in a `_transfer()` call of `DoubleEntryPoint._transfer(CryptoVault, player, 100);`.

Our Forta bot needs to raise an alert if the address to `CryptoVault` is passed as the `origSender` argument to `delegateTransfer()`. This bot also needs an `IDetectionBot` interface with the `handleTransaction()` function so we can raise the aforementioned alert based on our checks, if needed. To detect whether

To pass this level, deploy `DoubleEntryPointBot` from `DoubleEntryPointBot.sol` passing in the address of the `CryptoVault` in the `constructor()`. Then, we must call `setDecectionBot` in the `Forta` contract with our bot's address. To do that, we can deploy the `IForta` interface at the address of the `Forta` contract, which we can get with the console command: `await contract.forta();`.