// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {PausableLib} from "src/modules/security/PausableLib.sol";

abstract contract Pausable {
    modifier whenPaused() {
        PausableLib.whenPaused();
        _;
    }

    modifier whenNotPaused() {
        PausableLib.whenNotPaused();
        _;
    }
}
