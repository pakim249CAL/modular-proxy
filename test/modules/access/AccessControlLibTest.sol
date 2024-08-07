// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";

import {EnumerableSet} from "@openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

import {AccessControlLib, AccessControlStorage} from "src/modules/access/access_control/AccessControlLib.sol";

contract AccessControlLibTest is Test {
    using AccessControlLib for bytes32;
    using EnumerableSet for EnumerableSet.AddressSet;

    function testHasRole(bytes32 role, address account) public {
        assertFalse(role.hasRole(account));
        role.grantRole(account);
        assertTrue(role.hasRole(account));
        role.grantRole(account);
        assertTrue(role.hasRole(account));
        role.revokeRole(account);
        assertFalse(role.hasRole(account));
        role.revokeRole(account);
        assertFalse(role.hasRole(account));
    }

    function testCheckRole(bytes32 role, address account) public {
        role.grantRole(account);
        this.checkRole(role, account);

        role.revokeRole(account);
        vm.expectRevert(abi.encodeWithSelector(AccessControlLib.MissingRole.selector, role, account));
        this.checkRole(role, account);
    }

    function testSetRoleAdmin(bytes32 role, bytes32 adminRole) public {
        vm.expectEmit(address(this));
        emit AccessControlLib.RoleAdminChanged(role, bytes32(0), adminRole);
        this.setRoleAdmin(role, adminRole);
        assertEq(role.getRoleAdmin(), adminRole);
    }

    function testGrantRole(bytes32 role, address account) public {
        vm.expectEmit(address(this));
        emit AccessControlLib.RoleGranted(role, account);
        this.grantRole(role, account);
        assertEq(role.getRoleMemberCount(), 1);
        assertEq(role.getRoleMember(0), account);

        vm.expectEmit(address(this));
        emit AccessControlLib.RoleGranted(role, account);
        this.grantRole(role, account);
        assertEq(role.getRoleMemberCount(), 1);
        assertEq(role.getRoleMember(0), account);
    }

    function testRevokeRole(bytes32 role, address account) public {
        role.grantRole(account);

        vm.expectEmit(address(this));
        emit AccessControlLib.RoleRevoked(role, account);
        this.revokeRole(role, account);
        assertEq(role.getRoleMemberCount(), 0);

        vm.expectEmit(address(this));
        emit AccessControlLib.RoleRevoked(role, account);
        this.revokeRole(role, account);
        assertEq(role.getRoleMemberCount(), 0);
    }

    /// TESTING HARNESS ///

    function checkRole(bytes32 role, address account) external view {
        AccessControlLib.checkRole(role, account);
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole) external {
        AccessControlLib.setRoleAdmin(role, adminRole);
    }

    function grantRole(bytes32 role, address account) external {
        AccessControlLib.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external {
        AccessControlLib.revokeRole(role, account);
    }
}
