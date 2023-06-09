# Motorbike

The goal of this level is to `selfdestruct` the `Engine` contract making the motorbike unusable. This level uses a Universal Upgradeable Proxy Standard (UUPS) where the contract upgrade logic is written in the implementation and not the proxy, and there is a storage slot defined in the proxy contract for the address of the logic layer. Here, the proxy contract is `Motorbike` with `Engine` being the implementation contract. Interestingly, there isn't a `selfdestruct()` call anywhere within the `Engine` contract, but there is `upgradeToAndCall()` which ugrades the logic by calling `_authorizeUpgrade()`, verifying that the `msg.sender` is the `upgrader`:
```
function upgradeToAndCall(address newImplementation, bytes memory data) external payable {
    _authorizeUpgrade();
    _upgradeToAndCall(newImplementation, data);
}
```
The `upgrader` is set in the `initialize()` function:
```
function initialize() external initializer {
    horsePower = 1000;
    upgrader = msg.sender;
}
```
This is a special function in the UUPS as it acts as a constructor, that is only called once due to the `initializer` modifier. The issue with this function is that, although `initialize()` is being called by the proxy, it is doing so using a `delegatecall()`. Thus, the `delegatecall()` is being made within the context of the proxy and not the implementation. So, the implementation contract hasn't called `initialize()` yet. In order to break this level, we can find the address of the implementation contract and call `initialize()` ourselves making our `msg.sender` the `upgrader`. And once we are the `upgrader` we can call the `upgradeToAndCall()` passing in our own malicious contract with a `selfdestruct()`. The big hint for this attack vector is found in the [source code of Initializable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/58fa0f81c4036f1a3b616fdffad2fd27e5d5ce21/contracts/proxy/utils/Initializable.sol#L40). You could've also deployed an `Engine` interface at the returned address with an `upgrader()` function to get the `upgrader` address, seeing that `Engine`'s state has not been updated yet.

To get the address of the implementation, we can use the console on the level's page as we already have the `_IMPLEMENTATION_SLOT` found in `Engine`:
```
await web3.eth.getStorageAt(contract.address, "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc");
In my case: 0x000000000000000000000000fc2fe33ec53292acb417335494fe2fe0685ca63b
And we remove the leading zeros for the address: 0xfc2fe33ec53292acb417335494fe2fe0685ca63b
```
To hack the contract, we can deploy our own malicious contract `AttackMotorbike`, which is found in `AttackMotorbike.sol`. Here, we can have a `hack()` function that takes in a target address of type `IEngine` - an `Engine` interface that we've defined with an `initialize()` and `upgradeToAndCall(address, bytes memory)` funciton. We can use this to hack `Motorbike` to become the `upgrader` and pass in a `selfdestruct` call via `destroy()`.