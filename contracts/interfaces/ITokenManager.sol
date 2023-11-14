// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITokenManager {
    function addToken(address token) external;

    function removeToken(address token) external;

    function isTokenWhitelisted(address token) external view returns (bool);

    function viewCountWhitelistedTokens() external view returns (uint256);
}
