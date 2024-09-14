// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AccessControlLib} from "src/modules/access/AccessControlLib.sol";

abstract contract AccessControl {
    modifier onlyRole(bytes32 role) {
        AccessControlLib.checkRole(role, msg.sender);
        _;
    }
}
