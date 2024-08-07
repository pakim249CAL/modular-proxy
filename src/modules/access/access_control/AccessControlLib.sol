// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {EnumerableSet} from "@openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";y

/// @notice Storage layout for the AccessControlLib library following ERC-7201
library AccessControlStorage {
    string internal constant ACCESS_CONTROL_STORAGE_ID = "layer.n.access.control";
    bytes32 internal constant ACCESS_CONTROL_STORAGE_POSITION = keccak256(
        abi.encode(uint256(keccak256(abi.encodePacked(ACCESS_CONTROL_STORAGE_ID))) - 1)
    ) & ~bytes32(uint256(0xff));

    /// @custom:storage-location erc7201:layer.n.access.control.storage
    struct Layout {
        mapping(bytes32 => AccessControlLib.RoleData) roles;
    }

    function layout() internal pure returns (Layout storage acs) {
        bytes32 position = ACCESS_CONTROL_STORAGE_POSITION;
        assembly {
            acs.slot := position
        }
    }
}

library AccessControlLib {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account);

    event RoleRevoked(bytes32 indexed role, address indexed account);

    error MissingRole(bytes32 role, address account);

    function acs() internal pure returns (AccessControlStorage.Layout storage) {
        return AccessControlStorage.layout();
    }

    function hasRole(bytes32 role, address account) internal view returns (bool) {
        return acs().roles[role].members.contains(account);
    }

    function checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) revert MissingRole(role, account);
    }

    function getRoleAdmin(bytes32 role) internal view returns (bytes32) {
        return acs().roles[role].adminRole;
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        bytes32 previousAdminRole = getRoleAdmin(role);
        acs().roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function grantRole(bytes32 role, address account) internal {
        acs().roles[role].members.add(account);
        emit RoleGranted(role, account);
    }

    function revokeRole(bytes32 role, address account) internal {
        acs().roles[role].members.remove(account);
        emit RoleRevoked(role, account);
    }

    function getRoleMember(bytes32 role, uint256 index) internal view returns (address) {
        return acs().roles[role].members.at(index);
    }

    function getRoleMemberCount(bytes32 role) internal view returns (uint256) {
        return acs().roles[role].members.length();
    }
}
