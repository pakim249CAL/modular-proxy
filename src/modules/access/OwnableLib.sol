// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library OwnableStorage {
    struct Layout {
        address owner;
    }

    string internal constant STORAGE_ID = "modular.ownable.storage";
    bytes32 internal constant STORAGE_POSITION =
        keccak256(abi.encode(uint256(keccak256(abi.encodePacked(STORAGE_ID))) - 1)) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage s) {
        bytes32 slot = STORAGE_POSITION;
        assembly {
            s.slot := slot
        }
    }
}

library OwnableLib {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    error NotOwner(address);
    error NotTransitiveOwner(address);

    function os() internal pure returns (OwnableStorage.Layout storage l) {
        return OwnableStorage.layout();
    }

    function init(address _owner) internal {
        os().owner = _owner;
    }

    function onlyOwner() internal view {
        if (msg.sender != owner()) revert NotOwner(msg.sender);
    }

    function onlyTransitiveOwner() internal view {
        if (msg.sender != transitiveOwner()) revert NotTransitiveOwner(msg.sender);
    }

    function owner() internal view returns (address) {
        return os().owner;
    }

    function transitiveOwner() internal view returns (address) {
        address ownerMem = owner();
        while (ownerMem.code.length > 0) {
            try IOwnable(ownerMem).owner() returns (address nextOwner) {
                ownerMem = nextOwner;
            } catch {
                break;
            }
        }
        return ownerMem;
    }
}

interface IOwnable {
    function owner() external view returns (address);
}
