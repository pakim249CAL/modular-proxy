// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ERC1155Storage {
    struct Layout {
        mapping(uint256 => mapping(address => uint256)) balances;
        mapping(address => mapping(address => bool)) operatorApprovals;
    }

    string internal constant STORAGE_ID = "modular.erc1155.storage";
    bytes32 internal constant STORAGE_POSITION =
        keccak256(abi.encode(uint256(keccak256(abi.encodePacked(STORAGE_ID))) - 1)) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_POSITION;
        assembly {
            l.slot := slot
        }
    }
}

library ERC1155Lib {}
