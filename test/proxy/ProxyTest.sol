// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";

import {ModularProxyStorage as S, ModularProxyLib as L} from "src/proxy/libraries/ModularProxyLib.sol";

import {ModularProxyGetters} from "src/proxy/facets/ModularProxyGetters.sol";

import {ModularProxy} from "src/proxy/ModularProxy.sol";

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract ProxyTest is Test {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    function testAddFunctionFailsIfSelectorAlreadyRegistered(address facet, bytes4 selector) public {
        vm.assume(facet != address(0));
        L.setFunction(facet, selector);

        vm.expectRevert("MultiFacetProxyLib: selector to add is already registered");
        L.addFunction(facet, selector);
    }

    function testRemoveFunctionFailsIfSelectorNotRegistered(bytes4 selector) public {
        vm.expectRevert("MultiFacetProxyLib: selector to remove is not registered");
        L.removeFunction(selector);
    }

    function testReplaceFunctionFailsIfSelectorNotRegistered(address facet, bytes4 selector) public {
        vm.assume(facet != address(0));
        vm.expectRevert("MultiFacetProxyLib: selector to replace is not registered");
        L.replaceFunction(facet, selector);
    }

    function testSetFunctionIfFacetNonZero(address facet, bytes4 selector) public {
        S.Layout storage ps = S.layout();

        vm.assume(facet != address(0));

        vm.expectEmit();
        emit L.FunctionSelectorSet(facet, selector);

        this.callSetFunction(facet, selector);
        assertEq(S.layout().selectorToFacet[selector], facet);
        assertEq(ps.selectors.length(), 1);
        assertTrue(ps.selectors.contains(bytes32(selector)));
    }

    function testSetFunctionIfFacetZero(address facet, bytes4 selector) public {
        S.Layout storage ps = S.layout();

        testSetFunctionIfFacetNonZero(facet, selector);

        vm.expectEmit();
        emit L.FunctionSelectorSet(address(0), selector);

        this.callSetFunction(address(0), selector);
        assertEq(ps.selectorToFacet[selector], address(0));
        assertEq(ps.selectors.length(), 0);
        assertFalse(ps.selectors.contains(bytes32(selector)));
    }

    function testDeployAndCalls() public {
        ModularProxyGetters getters = new ModularProxyGetters();

        L.SelectorMapping[] memory selectorMappings = new L.SelectorMapping[](1);
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = getters.getAllSelectors.selector;
        selectors[1] = getters.getFacet.selector;

        selectorMappings[0] = L.SelectorMapping(address(getters), selectors);

        address proxy = address(new ModularProxy(selectorMappings, address(0), ""));

        assertEq(ModularProxyGetters(proxy).getFacet(getters.getFacet.selector), address(getters));
        assertEq(ModularProxyGetters(proxy).getFacet(getters.getAllSelectors.selector), address(getters));
        assertEq(ModularProxyGetters(proxy).getAllSelectors().length, 2);
    }

    function testDeployWithInit() public {
        ModularProxyGetters getters = new ModularProxyGetters();
        TestInit init = new TestInit();

        L.SelectorMapping[] memory selectorMappings = new L.SelectorMapping[](1);
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = getters.getAllSelectors.selector;
        selectors[1] = getters.getFacet.selector;

        selectorMappings[0] = L.SelectorMapping(address(getters), selectors);

        address proxy = address(new ModularProxy(selectorMappings, address(init), abi.encodeCall(TestInit.init, ())));

        assertEq(ModularProxyGetters(proxy).getFacet(bytes4(0)), address(1));
    }

    function testCannotInitTwice() public {
        TestInit init = new TestInit();

        L.SelectorMapping[] memory selectorMappings = new L.SelectorMapping[](1);
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = init.init.selector;
        selectorMappings[0] = L.SelectorMapping(address(init), selectors);
        address proxy = address(new ModularProxy(selectorMappings, address(0), ""));
        TestInit(proxy).init();

        vm.expectRevert(abi.encodeWithSelector(TestInit.AlreadyInitialized.selector, address(init)));

        TestInit(proxy).init();
    }

    // HELPERS

    // Need to do an external call to emit events
    function callSetFunction(address facet, bytes4 selector) external {
        L.setFunction(facet, selector);
    }
}

contract TestInit {
    address immutable INIT_ADDRESS;

    error AlreadyInitialized(address init);

    constructor() {
        INIT_ADDRESS = address(this);
    }

    function init() public {
        if (S.layout().initialized[INIT_ADDRESS]) {
            revert AlreadyInitialized(INIT_ADDRESS);
        }
        S.layout().initialized[INIT_ADDRESS] = true;
        S.layout().selectorToFacet[bytes4(0)] = address(1);
    }
}
