// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { UUPSOwnable } from "../common/UUPSOwnable.sol";
import { ITokenManager } from "../interfaces/ITokenManager.sol";

contract Staking is UUPSOwnable, ReentrancyGuardUpgradeable {
    using SafeERC20 for IERC20;

    error StakingTokenNotWhitelisted();
    error ZeroAmount();
    error ZeroAddress();
    error LockedNotEnded();
    error InvalidEndTime();
    error InvalidStartTime();
    error InvalidStartOrEndTime();
    error InvalidStakingToken();
    error InvalidAmount();
    error AlreadyWithdrawn();

    event Deposited(
        address indexed account,
        address indexed stakingToken,
        uint256 amount,
        uint256 stakingType,
        uint256 lockedId,
        uint256 startTime,
        uint256 endTime
    );
    event Withdrawn(
        address indexed account,
        address indexed stakingToken,
        uint256 amount,
        uint256 lockedId,
        uint256 stakingType
    );
    event NewTokenManager(address indexed tokenManagerAddress);

    ITokenManager _tokenManager;

    // Total: staking token => staked amount
    mapping(address => uint256) private _totalSupply;
    // User: address => (staking token => staked amount)
    mapping(address => mapping(address => uint256)) private _balances;

    // User: address => locked staking id
    mapping(address => uint256) private _lockedId;

    struct LockedInfo {
        address stakingToken;
        uint256 stakingType;
        uint256 balance;
        uint256 startTime;
        uint256 endTime;
    }
    // User: address => (locked id => locked info)
    mapping(address => mapping(uint256 => LockedInfo)) private _lockedBalances;

    // User: address => (staking token => staked amount)
    mapping(address => mapping(address => uint256)) private _flexibleBalances;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address initialOwner,
        ITokenManager initialTokenManager
    ) public initializer {
        __UUPSOwnable_init(initialOwner);
        __ReentrancyGuard_init();

        _tokenManager = initialTokenManager;
    }

    function totalSupply(address stakingToken) external view returns (uint256) {
        return _totalSupply[stakingToken];
    }

    function balanceOf(address account, address stakingToken) external view returns (uint256) {
        return _balances[account][stakingToken];
    }

    function getLockedInfo(
        address account,
        uint256 lockedId
    ) external view returns (LockedInfo memory) {
        return _lockedBalances[account][lockedId];
    }

    function getLockedId(address account) external view returns (uint256) {
        return _lockedId[account];
    }

    function getFlexibleBalance(
        address account,
        address stakingToken
    ) external view returns (uint256) {
        return _flexibleBalances[account][stakingToken];
    }

    function tokenManager() external view returns (ITokenManager) {
        return _tokenManager;
    }

    function deposit(
        address stakingToken,
        uint256 amount,
        uint256 stakingType,
        uint256 startTime,
        uint256 endTime
    ) external nonReentrant {
        if (!_tokenManager.isTokenWhitelisted(address(stakingToken))) {
            revert StakingTokenNotWhitelisted();
        }

        if (amount == 0) {
            revert ZeroAmount();
        }

        uint256 lockedId;
        if (stakingType != 0) {
            if (block.timestamp > endTime) {
                revert InvalidEndTime();
            }

            if (startTime > endTime) {
                revert InvalidStartTime();
            }

            lockedId = _lockedId[msg.sender] + 1; // start from 1

            _lockedBalances[msg.sender][lockedId] = LockedInfo(
                stakingToken,
                stakingType,
                amount,
                startTime,
                endTime
            );
            _lockedId[msg.sender] = lockedId;
        } else {
            if (startTime != 0 || endTime != 0) {
                revert InvalidStartOrEndTime();
            }
            lockedId = 0;
            _flexibleBalances[msg.sender][stakingToken] += amount;
        }

        _totalSupply[stakingToken] += amount;
        _balances[msg.sender][stakingToken] += amount;
        IERC20(stakingToken).safeTransferFrom(msg.sender, address(this), amount);
        emit Deposited(msg.sender, stakingToken, amount, stakingType, lockedId, startTime, endTime);
    }

    function withdraw(address stakingToken, uint256 amount, uint256 lockedId) public nonReentrant {
        if (amount == 0) {
            revert ZeroAmount();
        }

        uint256 stakingType;
        if (lockedId != 0) {
            LockedInfo storage info = _lockedBalances[msg.sender][lockedId];

            if (block.timestamp < info.endTime) {
                revert LockedNotEnded();
            }
            if (amount != info.balance) {
                if (info.balance == 0) {
                    revert AlreadyWithdrawn();
                } else {
                    revert InvalidAmount();
                }
            }
            if (stakingToken != info.stakingToken) {
                revert InvalidStakingToken();
            }

            stakingType = info.stakingType;
            info.balance -= amount;
        } else {
            stakingType = 0;
            _flexibleBalances[msg.sender][stakingToken] -= amount;
        }

        _totalSupply[stakingToken] -= amount;
        _balances[msg.sender][stakingToken] -= amount;
        IERC20(stakingToken).safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, stakingToken, amount, lockedId, stakingType);
    }

    function setTokenManager(address newTokenManager) external onlyOwner {
        if (newTokenManager == address(0)) {
            revert ZeroAddress();
        }
        _tokenManager = ITokenManager(newTokenManager);
        emit NewTokenManager(newTokenManager);
    }
}
