// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ReentrancyGuardStorage {
    struct Layout {
        ReentrancyGuardLib.ReentrancyStatus status;
    }

    string internal constant STORAGE_ID = "modular.reentrancy.guard.storage";
    bytes32 internal constant STORAGE_POSITION =
        keccak256(abi.encode(uint256(keccak256(abi.encodePacked(STORAGE_ID))) - 1)) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage s) {
        bytes32 slot = STORAGE_POSITION;
        assembly {
            s.slot := slot
        }
    }
}

library ReentrancyGuardLib {
    error ReentrantCall();

    enum ReentrancyStatus {
        Uninitialized, // default value
        Unlocked,
        Locked
    }

    function rs() internal pure returns (ReentrancyGuardStorage.Layout storage) {
        return ReentrancyGuardStorage.layout();
    }

    function isReentrancyGuardLocked() internal view returns (bool) {
        return rs().status == ReentrancyStatus.Locked;
    }

    function lockReentrancyGuard() internal {
        rs().status = ReentrancyStatus.Locked;
    }

    function unlockReentrancyGuard() internal {
        rs().status = ReentrancyStatus.Unlocked;
    }
}

interface IOwnable {
    function owner() external view returns (address);
}
