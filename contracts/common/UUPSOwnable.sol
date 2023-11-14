// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract UUPSOwnable is UUPSUpgradeable, OwnableUpgradeable {
    function __UUPSOwnable_init(address initialOwner) internal onlyInitializing {
        __Ownable_init(initialOwner);
    }

    function _authorizeUpgrade(address) internal virtual override onlyOwner {}
}
