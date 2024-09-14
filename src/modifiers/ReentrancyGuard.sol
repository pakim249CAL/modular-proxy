// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ReentrancyGuardLib as L} from "src/modules/security/ReentrancyGuardLib.sol";

abstract contract ReentrancyGuard {
    modifier nonReentrant() {
        if (L.isReentrancyGuardLocked()) revert L.ReentrantCall();
        L.lockReentrancyGuard();
        _;
        L.unlockReentrancyGuard();
    }
}
