// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library PausableStorage {
    struct Layout {
        bool paused;
    }

    string internal constant STORAGE_ID = "modular.pausable.storage";
    bytes32 internal constant STORAGE_POSITION =
        keccak256(abi.encode(uint256(keccak256(abi.encodePacked(STORAGE_ID))) - 1)) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage s) {
        bytes32 slot = STORAGE_POSITION;
        assembly {
            s.slot := slot
        }
    }
}

library PausableLib {
    event PauseSet(bool);

    error Paused();
    error NotPaused();

    function ps() internal pure returns (PausableStorage.Layout storage) {
        return PausableStorage.layout();
    }

    function whenNotPaused() internal view {
        if (ps().paused) revert Paused();
    }

    function whenPaused() internal view {
        if (!ps().paused) revert NotPaused();
    }

    function pause() internal {
        if (ps().paused) revert Paused();
        ps().paused = true;
        emit PauseSet(true);
    }

    function unpause() internal {
        if (!ps().paused) revert NotPaused();
        ps().paused = false;
        emit PauseSet(false);
    }

    function paused() internal view returns (bool) {
        return ps().paused;
    }
}
