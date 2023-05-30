# Elevator

The goal of this contract is to reach the top floor of the building or set `top` equal to `true`.

The `gotTo()` function is the only function we can call in `Elevator`:
```
function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) {
      floor = _floor;
      top = building.isLastFloor(floor);
    }
}
```
The function creates an instance of the Building interface at the address of `msg.sender`. The Building interface is as follows:
```
interface Building {
  function isLastFloor(uint) external returns (bool);
}
```
Building has a function `isLastFloor()`, which returns a boolean. In order to set `top = true` in `goTo()`, `building.isLastFloor()` must return `false` to pass the if condition, and then return `true` in order to set the top. There are two ways to go about this but both require some sort of counter variable to keep track of:
- Have a boolean that we set conditionally
- Have a uint256 that we iterate and perform checks based on its value

The `isLastFloor()` function in `AttackElevator.sol` uses a boolean to pass these conditions. To pass the level, simply call the `hack()` function. `hack()` sends the elevator to the first floor, which is the returned as the last floor according to our `isLastFloor()` function. 