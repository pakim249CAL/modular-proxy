// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {OwnableLib} from "src/modules/access/OwnableLib.sol";

abstract contract Ownable {
    modifier onlyOwner() {
        OwnableLib.onlyOwner();
        _;
    }

    modifier onlyTransitiveOwner() {
        OwnableLib.onlyTransitiveOwner();
        _;
    }
}
