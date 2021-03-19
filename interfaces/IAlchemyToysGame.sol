pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier: MIT

/// @title AlchemyToysGame -
/// @notice The main game contract implementation
interface IAlchemyToysGame {
    enum ActionType {Pray, Melt, Sacrifice, Proclaim, Ascend}

    struct Action {
        uint256 key;
        uint256 timestamp;
        address payable addr;
        ActionType typ;
        bool done;
        uint256[] input;
        uint256[] output;
    }

    /// ACTIONS ///////////////////////////////////

    /**
    @notice Gives the sender 3 random new tokens/cards. Cost:

    -   1 turn
    -   turn fee

    I default configuration, there is a 1 in 8 chance of getting a card of 
    a higher level. So each new prayer card has a chance of

    -   1 in 8 to be a card of level 1
    -   1 in 64 to be a card of level 2
    -   1 in 512 to be a card of level 3
    -   ...
    -   1 in 16,777,216 to be the final level 9 card

    Since the card types are generated randomly it might take time
    until the cards appear in the sender's account, since it happens
    "asynchronously".
    */
    function pray() external payable;

    /**
    @notice Burn two tokens, giving one new token instead.
    Cost:

    - 1 turn
    - turn fee

    The level of the new token is one level higher than the mean of levels of the
    burned cards:

    (level token1 + level token2)/2 + 1 = level of the new card

    Which card the player gets is defined by epoch recipes that are reset each epoch.
    If there is no recipe for this card combination in this epoch, yet, the player
    will get an additional "gratis card" of one lesser level. So it pays off exploring new
    recipes!

    NOTE: Special tokens cannot be burned or melted (such as  the enlightenment and godhood tokens).

    @param token1Id - the id of the first token to burn
    @param token2Id - the id of the second token to burn
    */
    function melt(uint256 token1Id, uint256 token2Id) external payable;

    /**
    @notice Sacrifices a set of provided tokenIds, burning the tokens.

    This action does not cost and turns or have any temple fees. Each sacrifice counts
    towards enlightenment. As soon as the player burned one card of each token type that
    exists, he becomes the "enlightenment card", which is basically the ticket to be
    proclaimed God... and receive the accumulated temple treasure, of course.
    As a sacrifice to the new God.

    The number on the token cards to be sacrificed play a role, since they are summed
    into a "sacrifice index" for this player. If there are various enlightened players
    when the proclamation ceremony is triggered, the players of lower sacrifice index have
    priority and will receive bigger chunk of the treasure.

    During an epoch, there is a maximal amount of enlightened that can exist. So when a
    player sacrificed his last token card necessary to achieve enlightenment, but there
    are already X enlightened players waiting for proclamation, the transaction will fail
    and will be rolled back. The player will need to wait for the proclamation to happen,
    which will trigger a new epoch.

    @param tokenIds - a list of IDs that the player owns, to be burned/sacrificed.
     */
    function sacrifice(uint256[] memory tokenIds) external;

    /**
    @notice Proclaims new God(s). This can be started by any player, effectively assuming
    the role of a "prophet".

    It only makes sense proclaiming new God, when:

    1. at least one player has received an enlightenment token in this epoch and
    2. at least one full cycle has passed without any other player receiving enlightenment.

    The proclamation does the following:
    1. Get all available treasure and its distribution among shamans, enlightened, prophet, etc.
    2. Starting with the enlightened player (the one with lower sacrifice index) for each enlightened:
    3.  - Burn the enlightenment card token
    4.  - Give the godhood token
    5.  - Award part of the treasure as dictated by the distribution.
    6. Pay the temple shamans (into the GMT vault)
    7. Pay the prophet
    8. Start a new epoch
     */
    function proclaim() external;

    /// VIEWS ///////////////////////////////////

    /// @notice Returns the proof of sacrifice for the given address
    /// @dev the current value resets after enlightenment
    /// @param addr address to be checked
    /// @return current value that is incremented with each token sacrificed before enlightenment
    /// @return needed the value that has to be achieved for enlightenment
    function getSacrificeProof(address addr)
        external
        view
        returns (uint256 current, uint256 needed);

    /// @notice Returns the list of all sacrificed tokens by the address
    /// @dev it resets after enlightenment
    /// @param addr address to be checked
    /// @return list of all sacrificed tokens so far before enlightenment
    function getSacrifices(address addr)
        external
        view
        returns (uint256[] memory);

    /// @notice Returns the sacrifice index of the given address
    /// This is the sum of all numbers on the sacrificed token cards
    /// before enlightenment. It only plays a role, if there are several enlightened
    /// players during the proclamation ceremony. In this case the player
    /// with lower index (= sacrificed "older" token cards) has priority and
    /// gets a bigger treasury chunk.
    /// @dev it resets after enlightenment
    /// @param addr address to be checked
    /// @return index representing the sum of all numbers on the sacrificed token cards
    function getSacrificeIndex(address addr)
        external
        view
        returns (uint256 index);

    /// @notice Get the count of all prayers made by the given address
    /// @param addr address to check the log for
    /// @param history flag whether to check the history log or pending actions queue
    /// @return count of the addresse's actions in the log
    function actionsCount(address addr, bool history)
        external
        view
        returns (uint256 count);

    /// @notice Get the addresse's prayer at the given index
    /// @param addr address to be checked
    /// @param index of the prayer. You can call "prayersCount" first to get the boundaries.
    /// @param history flag whether to check history log or the pending queue
    /// @return action
    function actionAt(
        address addr,
        uint256 index,
        bool history
    ) external view returns (Action memory);

    /// @notice Get the sender's prayer by the given key
    /// @param key of the prayer
    /// @return Action
    function actionByKey(uint256 key) external view returns (Action memory);

    /// @notice Returns the count of enlightened players in the given epoch.
    /// @param epoch to be checked, 0 = current
    /// @return count of the enlightened payers
    function enlightenedCount(uint256 epoch)
        external
        view
        returns (uint256 count);

    /// @notice Returns the enlightenment card tokenId for the enlightened
    /// at the given index in this epoch
    /// @param index of the enlightened (use enlightenedCount to get limit)
    /// @param epoch to be checked. 0 = current
    /// @return enlightenedTokenId token ID of the enlightenement token card
    function enlightenedAt(uint256 index, uint256 epoch)
        external
        view
        returns (uint256 enlightenedTokenId);

    /// @notice Gets melting recipe for the given token pair and epoch
    /// @param token1Id of the token to melt
    /// @param token2Id of the token to melt
    /// @param epoch number, 0 = current epoch
    /// @return exists flag, if 0, discard the rest
    /// @return level of the resulting new card
    /// @return id of the resulting new card (id on that level 0...x)
    function getRecipe(
        uint256 token1Id,
        uint256 token2Id,
        uint256 epoch
    )
        external
        view
        returns (
            bool exists,
            uint256 level,
            uint256 id
        );

    /// @notice Emitted when something happens during the game such as:
    /// Pray, Melt, Sacrifice, Proclaim, Ascend. Check ActionTypes and Action.
    /// The key can be used to get the action details with actionByKey function.
    event Log(address addr, uint256 key);
}
