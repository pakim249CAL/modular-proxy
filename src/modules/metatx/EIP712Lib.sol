// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library EIP712Storage {
    struct Layout {
        bytes32 hashedName;
        bytes32 hashedVersion;
    }

    string internal constant STORAGE_ID = "modular.eip712.storage";
    bytes32 internal constant STORAGE_POSITION =
        keccak256(abi.encode(uint256(keccak256(abi.encodePacked(STORAGE_ID))) - 1)) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage s) {
        bytes32 slot = STORAGE_POSITION;
        assembly {
            s.slot := slot
        }
    }
}

library EIP712Lib {
    event PauseSet(bool);

    error Paused();
    error NotPaused();

    bytes32 internal constant EIP712_TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    function es() internal pure returns (EIP712Storage.Layout storage) {
        return EIP712Storage.layout();
    }

    function init(string memory name, string memory version) internal {
        es().hashedName = keccak256(abi.encodePacked(name));
        es().hashedVersion = keccak256(abi.encodePacked(version));
    }

    function calculateDomainSeparator(bytes32 nameHash, bytes32 versionHash) internal view returns (bytes32) {
        return keccak256(abi.encode(EIP712_TYPE_HASH, nameHash, versionHash, block.chainid, address(this)));
    }
}
