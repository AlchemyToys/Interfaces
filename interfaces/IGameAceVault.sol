pragma solidity 0.8.4;

// SPDX-License-Identifier: UNLICENSED

/// @title Vault for locking GAT tokens to participate in game treasury distribution
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
interface IGameAceVault {
    /// @notice Used by the game to add funds into the vault for the current epoch
    receive() external payable;

    /// @notice Used by the game to add funds into the vault for the current epoch
    function grant() external payable;

    /// @notice Locks the given amount of GAT tokens in the vault.
    /// The lock epoch (after which the sender is eligible for interests)
    /// is updated to the next epoch.
    /// Any pending interests for eligible past epochs are automatically paid out to
    /// prevent any loss.
    /// @param value How many GAT tockens to lock.
    function lock(uint256 value) external;

    /// @notice unlocks the GAT tokens, returning them back to the sender.
    /// Any pending interests for eligible past epochs are automatically paid out to
    /// prevent any loss.
    function unlock() external;

    /// @notice pays out any pending interests due to the sender for past epochs
    function payout() external returns (uint256 value);

    /// @notice updates epoch data, rolling over the tokens sums from previous epochs
    function updateEpochData() external;

    /// @notice Returns the tokens locked and the effective epoch for the sender's address
    /// @return tokens currently locked
    /// @return epoch after which the interests can be paid out
    function getLock() external view returns (uint256 tokens, uint256 epoch);

    /// @notice Returns the tokens locked and the effective epoch for the given address
    /// @param addr address to be checked
    /// @return tokens currently locked
    /// @return epoch after which the interests can be paid out
    function getLock(address addr)
        external
        view
        returns (uint256 tokens, uint256 epoch);

    /// @notice Checks if the sender's address is eligible for treasury distribution
    /// Only locks from previous epochs are eligible for distribution
    /// @return eligibility boolean flag
    function isEligible() external view returns (bool);

    /// @notice Checks if the address is eligible for treasury distribution
    /// Only locks from previous epochs are eligible for distribution
    /// @param addr address to check eligibility for
    /// @return eligibility boolean flag
    function isEligible(address addr) external view returns (bool);

    /// @notice Get the total interests for past epochs that can be withdrawn
    /// @return totalInterest amount in ether that the sender can withdraw
    function getTotalEligible() external view returns (uint256 totalInterest);

    /// @notice Get the total interests for past epochs that can be withdrawn
    /// @return totalInterest amount in ether that the address can withdraw
    function getTotalEligible(address payable addr)
        external
        view
        returns (uint256 totalInterest);

    /// @notice Returns current epoch
    /// @return epoch
    function getEpoch() external view returns (uint256 epoch);

    /// @notice Returns total of GAT tokens and ether still locked/unpaid for the current epoch
    /// @return tokens sum of GAT
    /// @return eth sum
    function getEpochVault()
        external
        view
        returns (uint256 tokens, uint256 eth);

    /// @notice Returns total of GAT tokens and ether still locked/unpaid a the given epoch
    /// @param epoch to be checked
    /// @return tokens sum of GAT
    /// @return eth sum
    function getEpochVault(uint256 epoch)
        external
        view
        returns (uint256 tokens, uint256 eth);

    /// @notice Emitted when someone locks an amount
    /// @param addr address of the sender locking the amount
    /// @param epoch starting from which the tokens will be eligible for interests
    /// @param value being locked
    /// @param totalValue sum of all currently locked GAT tokens for the given address
    event Lock(
        address indexed addr,
        uint256 epoch,
        uint256 value,
        uint256 totalValue
    );

    /// @notice Emitted when someone unlocks GAT tokens
    /// @param addr of the sender that unlocks the GAT tokens
    /// @param totalValue amount being unlocked
    event Unlock(address indexed addr, uint256 totalValue);

    /// @notice Emitted when someone gets paid
    /// @param addr of the beneficiary
    /// @param startEpoch of the payout
    /// @param endEpoch of the payout (current epoch - 1)
    /// @param totalValue in eother that has been paid out
    event Payout(
        address indexed addr,
        uint256 startEpoch,
        uint256 endEpoch,
        uint256 totalValue
    );
}
