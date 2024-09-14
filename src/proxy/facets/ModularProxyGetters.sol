// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ModularProxyStorage as S} from "src/proxy/libraries/ModularProxyLib.sol";
import {IModularProxyGetters} from "src/proxy/facets/IModularProxyGetters.sol";

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// TODO: When the TSTORE and TLOAD opcodes are available, add support for IDiamondLoupe
contract ModularProxyGetters is IModularProxyGetters {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /// @notice Returns all selectors registered in the proxy. Meant for off-chain use, as it is not gas efficient.
    function getAllSelectors() external view returns (bytes4[] memory selectors) {
        S.Layout storage ps = S.layout();
        selectors = new bytes4[](ps.selectors.length());
        for (uint256 i; i < selectors.length; i++) {
            // Solidity uses big-endian for bytes, and little endian for uints. So we need to convert.
            selectors[i] = bytes4(uint32(uint256(ps.selectors.at(i)) >> 224));
        }
    }

    /// @notice Returns the facet address for a given selector.
    function getFacet(bytes4 selector) external view returns (address facet) {
        return S.layout().selectorToFacet[selector];
    }
}
