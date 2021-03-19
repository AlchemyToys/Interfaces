pragma solidity 0.6.12;

// SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Control of epochs and cycles and user turns
/// @notice Controls epochs and cycles switching
interface ITimer {
    /// @notice Will incrase the cycle, if the current block timestamp
    /// is more than the lastCycleStart + cycleLength.
    /// @dev BEWARE: it will only increase the cycle by one. Even if multiple counts
    /// of cycleLength have passed since the last call
    /// @return whether cycle has been increased
    function changeCycle() external returns (bool);

    /// @notice Increases the epoch by one
    function changeEpoch() external;

    /// @notice returns current cycle
    /// return cycle
    function getCycle() external view returns (uint256);

    /// @notice returns current epoch
    /// @return epoch
    function getEpoch() external view returns (uint256);

    /// @notice returns the cycle length in seconds
    /// @return cycleLength
    function getCycleLength() external view returns (uint256);

    /// @notice returns blocktime of the last cycle start
    /// @return lastcycleStart
    function getLastCycleStart() external view returns (uint256);

    /// @notice Returns how many turns the address has left for this cycle
    /// @param addr address to be queried
    /// @return turns left
    function getTurnsLeft(address addr) external view returns (uint256);

    /// @notice gets limits of turns per cycle
    /// @return turnLimit
    function getTurnLimit() external view returns (uint256);

    /// @notice Makes one turn. Fails if not enough turns left in this cycle
    function makeTurn(address addr) external;

    /// @notice Makes X turns. Fails if not enough turns left in this cycle
    /// @param many How many turns to make
    function makeTurns(address addr, uint256 many) external;

    /// @notice Emitted when cycle increases
    /// @param cycle the new cycle value
    event Cycle(uint256 cycle);

    /// @notice Emitted when epoch increases
    /// @param epoch the new epoch value
    event Epoch(uint256 epoch);

    /// @notice Emitted when a user makes turns
    /// @param addr of the user
    /// @param cycle during which the turn happened
    /// @param many how many turns were made
    /// @param left how many turns are left in this cycle
    event Turn(address addr, uint256 cycle, uint256 many, uint256 left);
}
