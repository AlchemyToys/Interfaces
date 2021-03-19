pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol";

/// @title AlchemyToysToken - Game Master Token ERC20 implementation
/// @notice Simple implementation of a {ERC20} token to be used as
// Game Master Token (GMT)
interface IAlchemyToysToken is IERC721, IERC721Metadata, IERC721Enumerable {
    /// @notice Returns configuration options of the ATT contract
    /// @return levels configuration array
    /// @return base of the levels - how many tokens the first level has
    /// @return count of the levels
    /// @return levelOffset for token indexing
    /// @return baseOffset for token level id generation
    function getLevelsConfig()
        external
        view
        returns (
            uint256[][] memory levels,
            uint256 base,
            uint256 count,
            uint256 levelOffset,
            uint256 baseOffset
        );

    /// @notice Returns information about a token
    /// @param tokenId of the token to be checked
    /// @return id on the level of the token, since each token has a level id. For example,
    ///         level 0 has token ids ranging from 0 to 255,
    ///         level 1 has token ids ranging from 0 to 127,
    ///         etc.
    /// @return level of the token
    /// @return number of the token
    function tokenInfo(uint256 tokenId)
        external
        view
        returns (
            uint256 id,
            uint256 level,
            uint256 number
        );

    /// @notice Returns a special token pair ID that can be used in recipes
    /// @dev Fails for special tokens, always returns same ID for two token types,
    /// independently of the order
    /// @param token1Id of the first token
    /// @param token2Id of the second token
    /// @return token pair ID
    function tokenPairID(uint256 token1Id, uint256 token2Id)
        external
        view
        returns (uint256);

    /// @notice Returns if the given token is a special one
    /// @param tokenId of the token to be checked
    /// @return boolean flag whether the token is special
    function isSpecialToken(uint256 tokenId) external view returns (bool);

    /// @notice Mints a new token for the specified address
    /// @dev can only be performed by owner of the contract, fails if level or id is overflown
    /// @param addr to receive the token
    /// @param id of the token type at the given level
    /// @param level of the token
    /// @return tokenID of the newly created token
    function give(
        address addr,
        uint256 id,
        uint256 level
    ) external returns (uint256 tokenID);

    /// @notice Mints new  non-special tokens for the specified address
    /// @dev used for testing purposes only
    /// @param addr to receive the tokens
    function giveAll(address addr, uint256[] memory tokenIds) external;

    /// @notice Burns the token, fails if it's not owned by anyone
    /// @param tokenId of the token
    function burn(uint256 tokenId) external;
}
