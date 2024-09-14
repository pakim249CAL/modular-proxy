// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

library ModularProxyStorage {
    struct Layout {
        mapping(bytes4 => address) selectorToFacet; // Maps function selectors to their respective facets
        EnumerableSet.Bytes32Set selectors; // Keeps track of all registered selectors
        mapping(address => bool) initialized; // Optional mapping for usage by initialization contracts
    }

    string internal constant STORAGE_ID = "modular.proxy.storage";
    bytes32 internal constant STORAGE_POSITION =
        keccak256(abi.encode(uint256(keccak256(abi.encodePacked(STORAGE_ID))) - 1)) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage s) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}

library ModularProxyLib {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    event FunctionSelectorSet(address facet, bytes4 selector);

    error AlreadyInitialized(address init);

    struct SelectorMapping {
        address facet;
        bytes4[] selectors;
    }

    function addFunctions(SelectorMapping[] memory selectorMappings) internal {
        for (uint256 i; i < selectorMappings.length; i++) {
            for (uint256 j; j < selectorMappings[i].selectors.length; j++) {
                addFunction(selectorMappings[i].facet, selectorMappings[i].selectors[j]);
            }
        }
    }

    function replaceFunctions(SelectorMapping[] memory selectorMappings) internal {
        for (uint256 i; i < selectorMappings.length; i++) {
            for (uint256 j; j < selectorMappings[i].selectors.length; j++) {
                replaceFunction(selectorMappings[i].facet, selectorMappings[i].selectors[j]);
            }
        }
    }

    function removeFunctions(bytes4[] memory selectors) internal {
        for (uint256 i; i < selectors.length; i++) {
            removeFunction(selectors[i]);
        }
    }

    // Using string errors here since we don't need gas efficiency for any upgrade facet and this can be decoded without the ABI.
    function addFunction(address facet, bytes4 selector) internal {
        require(
            !ModularProxyStorage.layout().selectors.contains(bytes32(selector)),
            "MultiFacetProxyLib: selector to add is already registered"
        );
        setFunction(facet, selector);
    }

    function removeFunction(bytes4 selector) internal {
        require(
            ModularProxyStorage.layout().selectors.contains(bytes32(selector)),
            "MultiFacetProxyLib: selector to remove is not registered"
        );
        setFunction(address(0), selector);
    }

    function replaceFunction(address facet, bytes4 selector) internal {
        require(
            ModularProxyStorage.layout().selectors.contains(bytes32(selector)),
            "MultiFacetProxyLib: selector to replace is not registered"
        );
        setFunction(facet, selector);
    }

    function delegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return Address.functionDelegateCall(target, data);
    }

    /// @notice Sets a function selector to a facet address, and adds/removes from the full selector set depending on if the facet address is zero.
    function setFunction(address facet, bytes4 selector) internal {
        ModularProxyStorage.Layout storage ps = ModularProxyStorage.layout();

        if (facet == address(0)) {
            ps.selectors.remove(bytes32(selector));
        } else {
            ps.selectors.add(bytes32(selector));
        }
        ps.selectorToFacet[selector] = facet;
        emit FunctionSelectorSet(facet, selector);
    }
}
