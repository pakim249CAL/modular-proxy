// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MultiFacetProxyStorage} from "src/proxy/libraries/MultiFacetProxyStorage.sol";

import {MultiFacetProxyLib} from "src/proxy/libraries/MultiFacetProxyLib.sol";
import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";

/// @notice This proxy maintains a mapping of function selectors to their respective implementations.
///         The fallback is modified to forward delegate calls based on this mapping.
contract MultiFacetProxy is Proxy {
    error FunctionNotFound(bytes4 selector);

    /// @notice Populates the MultiFacetProxy with the given selector mappings and optionally calls an init function
    /// @param selectorMappings Array of SelectorMapping structs
    /// @param init If non-zero, this address will be delegate called with initData on construction
    /// @param initData The calldata for the delegate call to init
    constructor(MultiFacetProxyLib.SelectorMapping[] memory selectorMappings, address init, bytes memory initData)
        payable
    {
        MultiFacetProxyLib.addFunctions(selectorMappings);

        // Discards return data
        if (init != address(0)) MultiFacetProxyLib.delegateCall(init, initData);
    }

    function _fallback() internal virtual override {
        address facet = _implementation();
        if (facet == address(0)) {
            revert FunctionNotFound(msg.sig);
        }
        _delegate(facet);
    }

    function _implementation() internal view virtual override returns (address) {
        return MultiFacetProxyStorage.layout().selectorToFacet[msg.sig];
    }

    receive() external payable {}
}
