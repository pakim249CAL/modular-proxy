// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ERC20Storage {
    struct Layout {
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
        uint256 totalSupply;
        string name;
        string symbol;
        uint8 decimals;
    }

    string internal constant STORAGE_ID = "modular.erc20.storage";
    bytes32 internal constant STORAGE_POSITION =
        keccak256(abi.encode(uint256(keccak256(abi.encodePacked(STORAGE_ID))) - 1)) & ~bytes32(uint256(0xff));

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_POSITION;
        assembly {
            l.slot := slot
        }
    }
}

library ERC20Lib {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    error ApproveFromZeroAddress();
    error ApproveToZeroAddress();
    error BurnExceedsBalance();
    error BurnFromZeroAddress();
    error InsufficientAllowance();
    error MintToZeroAddress();
    error TransferExceedsBalance();
    error TransferFromZeroAddress();
    error TransferToZeroAddress();
    error ExcessiveAllowance();

    function es() internal pure returns (ERC20Storage.Layout storage) {
        return ERC20Storage.layout();
    }

    function init_metadata(string memory _name, string memory _symbol, uint8 _decimals) internal {
        setName(_name);
        setSymbol(_symbol);
        setDecimals(_decimals);
    }

    // BASE FUNCTIONS

    /// @dev Make sure to return a bool in the external function call to comply with EIP-20
    function approve(address holder, address spender, uint256 amount) internal {
        if (holder == address(0)) revert ApproveFromZeroAddress();
        if (spender == address(0)) revert ApproveToZeroAddress();

        es().allowances[holder][spender] = amount;

        emit Approval(holder, spender, amount);
    }

    function increaseAllowance(address spender, uint256 amount) internal {
        uint256 allowance_ = allowance(msg.sender, spender);

        unchecked {
            if (allowance_ > allowance_ + amount) revert ExcessiveAllowance();
            approve(msg.sender, spender, allowance_ + amount);
        }
    }

    function decreaseAllowance(address holder, address spender, uint256 amount) internal {
        uint256 allowance_ = allowance(holder, spender);

        if (amount > allowance_) revert InsufficientAllowance();

        unchecked {
            approve(holder, spender, allowance_ - amount);
        }
    }

    function mint(address account, uint256 amount) internal {
        if (account == address(0)) revert MintToZeroAddress();

        es().totalSupply += amount;
        es().balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) internal {
        if (account == address(0)) revert BurnFromZeroAddress();

        uint256 accountBalance = balanceOf(account);

        if (amount > accountBalance) revert BurnExceedsBalance();

        unchecked {
            es().balances[account] -= amount;
        }
        es().totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /// @dev Make sure to return a bool in the external function call to comply with EIP-20
    function transfer(address holder, address recipient, uint256 amount) internal {
        if (holder == address(0)) revert TransferFromZeroAddress();
        if (recipient == address(0)) revert TransferToZeroAddress();

        uint256 holderBalance = balanceOf(holder);

        if (amount > holderBalance) revert TransferExceedsBalance();

        unchecked {
            es().balances[holder] -= amount;
        }
        es().balances[recipient] += amount;

        emit Transfer(holder, recipient, amount);
    }

    /// @dev Make sure to return a bool in the external function call to comply with EIP-20
    function transferFrom(address holder, address recipient, uint256 amount) internal {
        decreaseAllowance(holder, msg.sender, amount);

        transfer(holder, recipient, amount);
    }

    // METADATA FUNCTIONS

    function setName(string memory _name) internal {
        es().name = _name;
    }

    function setSymbol(string memory _symbol) internal {
        es().symbol = _symbol;
    }

    function setDecimals(uint8 _decimals) internal {
        es().decimals = _decimals;
    }

    // BASE VIEW

    function totalSupply() internal view returns (uint256) {
        return es().totalSupply;
    }

    function balanceOf(address account) internal view returns (uint256) {
        return es().balances[account];
    }

    function allowance(address holder, address spender) internal view returns (uint256) {
        return es().allowances[holder][spender];
    }

    // METADATA VIEW

    function name() internal view returns (string memory) {
        return es().name;
    }

    function symbol() internal view returns (string memory) {
        return es().symbol;
    }

    function decimals() internal view returns (uint8) {
        return es().decimals;
    }
}
