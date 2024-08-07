// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @notice Storage layout for the MultiFacetProxy following ERC-7201
library MultiFacetProxyStorage {
    string internal constant MULTI_FACET_PROXY_STORAGE_ID = "multi.facet.proxy.storage";
    bytes32 internal constant MULTI_FACET_PROXY_STORAGE_POSITION = keccak256(
        abi.encode(uint256(keccak256(abi.encodePacked(MULTI_FACET_PROXY_STORAGE_ID))) - 1)
    ) & ~bytes32(uint256(0xff));

    /// @custom:storage-location erc7201:multi.facet.proxy.storage
    struct Layout {
        mapping(bytes4 => address) selectorToFacet; // Maps function selectors to their respective facets
        EnumerableSet.Bytes32Set selectors; // Keeps track of all registered selectors
        mapping(address => bool) initialized; // Optional mapping for usage by initialization contracts
    }

    function layout() internal pure returns (Layout storage ps) {
        bytes32 position = MULTI_FACET_PROXY_STORAGE_POSITION;
        assembly {
            ps.slot := position
        }
    }
}
