// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { ITokenManager } from "../interfaces/ITokenManager.sol";

/**
 * @title TokenManager
 * @dev Manages the token whitelist
 */
contract TokenManager is ITokenManager, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    error AlreadyWhitelisted();
    error NotWhitelisted();

    event TokenRemoved(address indexed token);
    event TokenWhitelisted(address indexed token);

    EnumerableSet.AddressSet private _whitelistedTokens;

    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @notice Add matching token
     * @param token address of token to add
     */
    function addToken(address token) external onlyOwner {
        if (_whitelistedTokens.contains(token)) revert AlreadyWhitelisted();
        _whitelistedTokens.add(token);

        emit TokenWhitelisted(token);
    }

    /**
     * @notice Remove matching token
     * @param token address of token to remove
     */
    function removeToken(address token) external onlyOwner {
        if (!_whitelistedTokens.contains(token)) revert NotWhitelisted();
        _whitelistedTokens.remove(token);

        emit TokenRemoved(token);
    }

    /**
     * @notice Returns if a token has been added
     * @param token address of the token to check
     */
    function isTokenWhitelisted(address token) external view returns (bool) {
        return _whitelistedTokens.contains(token);
    }

    /**
     * @notice View number of whitelisted policies
     */
    function viewCountWhitelistedTokens() external view returns (uint256) {
        return _whitelistedTokens.length();
    }

    /**
     * @notice See whitelisted policies
     * @param cursor cursor
     * @param size size
     */
    function viewWhitelistedTokens(
        uint256 cursor,
        uint256 size
    ) external view returns (address[] memory, uint256) {
        uint256 length = size;

        if (length > _whitelistedTokens.length() - cursor) {
            length = _whitelistedTokens.length() - cursor;
        }

        address[] memory whitelistedTokens = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            whitelistedTokens[i] = _whitelistedTokens.at(cursor + i);
        }

        return (whitelistedTokens, cursor + length);
    }
}
