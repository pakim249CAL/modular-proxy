// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

import {ERC721Utils} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Utils.sol";

library ERC721Storage {
    struct Layout {
        EnumerableMap.UintToAddressMap tokenOwners;
        mapping(address => EnumerableSet.UintSet) holderTokens;
        mapping(uint256 => address) tokenApprovals;
        mapping(address => mapping(address => bool)) operatorApprovals;
        string name;
        string symbol;
        string baseURI;
        mapping(uint256 => string) tokenURIs;
    }

    string internal constant STORAGE_ID = "modular.erc721.storage";
    bytes32 internal constant STORAGE_POSITION =
        keccak256(abi.encode(uint256(keccak256(abi.encodePacked(STORAGE_ID))) - 1)) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage s) {
        bytes32 slot = STORAGE_POSITION;
        assembly {
            s.slot := slot
        }
    }
}

library ERC721Lib {
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using EnumerableSet for EnumerableSet.UintSet;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed operator, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    error NotOwnerOrApproved();
    error SelfApproval();
    error BalanceQueryZeroAddress();
    error ERC721ReceiverNotImplemented();
    error InvalidOwner();
    error MintToZeroAddress();
    error NonExistentToken();
    error NotTokenOwner();
    error TokenAlreadyMinted();
    error TransferToZeroAddress();

    function es() internal pure returns (ERC721Storage.Layout storage) {
        return ERC721Storage.layout();
    }

    function init_metadata(string memory _name, string memory _symbol, string memory _baseURI) internal {
        es().name = _name;
        es().symbol = _symbol;
        es().baseURI = _baseURI;
    }

    function balanceOf(address owner) internal view returns (uint256) {
        return es().holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) internal view returns (address) {
        address owner = es().tokenOwners.get(tokenId);
        if (owner == address(0)) revert InvalidOwner();
        return owner;
    }

    function exists(uint256 tokenId) internal view returns (bool) {
        return es().tokenOwners.contains(tokenId);
    }

    function getApproved(uint256 tokenId) internal view returns (address) {
        if (!exists(tokenId)) revert NonExistentToken();
        return es().tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) internal view returns (bool) {
        return es().operatorApprovals[owner][operator];
    }

    function isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        if (!exists(tokenId)) revert NonExistentToken();

        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function mint(address to, uint256 tokenId) internal {
        if (to == address(0)) revert MintToZeroAddress();
        if (exists(tokenId)) revert TokenAlreadyMinted();

        es().holderTokens[to].add(tokenId);
        es().tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function safeMint(address to, uint256 tokenId) internal {
        safeMint(to, tokenId, "");
    }

    function safeMint(address to, uint256 tokenId, bytes memory data) internal {
        mint(to, tokenId);
        checkOnERC721Received(address(0), to, tokenId, data);
    }

    function transfer(address from, address to, uint256 tokenId) internal {
        if (ownerOf(tokenId) != from) revert NotTokenOwner();
        if (to == address(0)) revert TransferToZeroAddress();

        es().holderTokens[from].remove(tokenId);
        es().holderTokens[to].add(tokenId);
        es().tokenOwners.set(tokenId, to);
        es().tokenApprovals[tokenId] = address(0);

        emit Approval(from, address(0), tokenId);
        emit Transfer(from, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) internal {
        if (!isApprovedOrOwner(msg.sender, tokenId)) revert NotOwnerOrApproved();
        transfer(from, to, tokenId);
    }

    function safeTransfer(address from, address to, uint256 tokenId) internal {
        safeTransfer(from, to, tokenId, "");
    }

    function safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal {
        transfer(from, to, tokenId);
        checkOnERC721Received(from, to, tokenId, data);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) internal {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) internal {
        transferFrom(from, to, tokenId);
        checkOnERC721Received(from, to, tokenId, data);
    }

    function approve(address operator, uint256 tokenId) internal {
        address owner = ownerOf(tokenId);
        if (operator == owner) revert SelfApproval();
        if (msg.sender != owner && !isApprovedForAll(owner, msg.sender)) revert NotOwnerOrApproved();

        es().tokenApprovals[tokenId] = operator;
        emit Approval(owner, operator, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) internal {
        if (operator == msg.sender) revert SelfApproval();
        es().operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) internal {
        ERC721Utils.checkOnERC721Received(msg.sender, from, to, tokenId, data);
    }

    // ENUMERABLE

    function totalSupply() internal view returns (uint256) {
        return es().tokenOwners.length();
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) internal view returns (uint256) {
        return es().holderTokens[owner].at(index);
    }

    function tokenByIndex(uint256 index) internal view returns (uint256) {
        (uint256 tokenId,) = es().tokenOwners.at(index);
        return tokenId;
    }

    // METADATA

    function name() internal view returns (string memory) {
        return es().name;
    }

    function symbol() internal view returns (string memory) {
        return es().symbol;
    }

    function tokenURI(uint256 tokenId) internal view returns (string memory) {
        return es().tokenURIs[tokenId];
    }
}
