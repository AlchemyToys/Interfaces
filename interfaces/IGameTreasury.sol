pragma solidity 0.6.12;

// SPDX-License-Identifier: UNLICENSED

/// @title Manages the trasury of the game
/// @notice manages the treasury of the game. The tasks of the contract include:
///         - Topping up of LINK tokens when they fall below certain level ✅
///         - Returning values available for payouts ✅
///         - Setting and returning the price of one turn
///         - Doing the actual payouts
interface IGameTreasury {
    /// @notice Percentage of treasury funds distributed to shamans on epoch change
    /// @return pctShamans
    function getPctShamans() external view returns (uint256);

    /// @notice Percentage of treasury funds distributed to winners on epoch change
    /// @return pctWinners
    function getPctWinners() external view returns (uint256);

    /// @notice Percentage of treasury funds distributed to the prophet on epoch change
    /// @return pctProphet
    function getPctProphet() external view returns (uint256);

    /// @notice returns turn fees in LINK token representation. These neven change and are static.
    /// @return turnLinkFee
    function getTurnLINKFee() external view returns (uint256);

    /// @notice returns Turn fees in ether token representation.
    /// These change each cycle, for example.
    /// depending on the current UniSwap exchange rate.
    /// @return turnFee
    function getTurnFee() external view returns (uint256);

    /// @notice Returns treasury distribution
    /// @dev uses pct* setting to calculate. Deducts a reserve required for minimal LINK purchase first.
    /// @return shamans ethereum value to distribute
    /// @return winners ethereum value to distribute
    /// @return prophet ethereum value to distribute
    /// @return linkReserve how much is kept in treasury for possible LINK purchases
    /// @return templeReserve how much is kept in treasury as a seed for the next epoch,
    ///         it is the rest after deducting all the other positions above
    function getTreasuryDistribution()
        external
        view
        returns (
            uint256 shamans,
            uint256 winners,
            uint256 prophet,
            uint256 linkReserve,
            uint256 templeReserve
        );

    /// @notice Check if the provided address
    /// @dev Should only be accessible by conract owner
    /// @param addr that has to have enough LINK
    function ensureFees(address addr) external payable;

    /// @notice Check for the current exchange rate and update the turnFee
    /// @dev Should only be accessible by conract owner
    function updateTurnFee() external;

    /// @notice Pays provided sum to the given address
    /// @param addr address to be paid to
    /// @param value to be transferred
    function pay(address payable addr, uint256 value) external;
}
