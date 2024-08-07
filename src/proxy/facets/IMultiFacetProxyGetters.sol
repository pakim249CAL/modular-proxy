// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IMultiFacetProxyGetters {
    function getAllSelectors() external view returns (bytes4[] memory selectors);

    function getFacet(bytes4 selector) external view returns (address facet);
}
