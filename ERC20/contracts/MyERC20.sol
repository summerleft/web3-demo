// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { IERC20 } from "../interface/IERC20.sol";

// todo:
// 一些边界条件的判断 
// done:
// 每次增发量不超过 1%
// 每个人都可以授权、销毁代币
// 增加量间隔为 1 年以上

contract MyERC20 is IERC20 {
    address private _owner;
    uint private _totalSupply;

    mapping(address => uint) private _balanceOf;
    mapping(address => mapping(address => uint)) private _allowance;

    uint256 private _lastMintTime;

    string private _name = "HeFirstToken";
    string private _symbol = "HE_TOKEN";
    uint8 private _decimals = 18;

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    constructor(uint256 initialSupply) {
        _owner = msg.sender;
        _totalSupply += initialSupply;
        _balanceOf[msg.sender] += initialSupply;
        _lastMintTime = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    // limit single supply amount
    modifier mintLimit(uint256 singleMintCount) {
        require(
            singleMintCount * 100 <= _totalSupply * 1,
            "Cannot mint tokens more than 1% of current supply"
        );
        _;
    }

    modifier mintGapLimit() {
        require(
            block.timestamp - _lastMintTime >= 365 days,
            "Cannot mint tokens within a one-year intaval"
        );
        _;
    }

    function mint(
        uint256 value
    ) external onlyOwner mintLimit(value) mintGapLimit {
        _balanceOf[msg.sender] += value;
        _totalSupply += value;
        _lastMintTime = block.timestamp;
        emit Transfer(address(0), msg.sender, value);
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balanceOf[account];
    }

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        return _allowance[owner][spender];
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _balanceOf[msg.sender] -= value;
        _balanceOf[msg.sender] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        _allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        _allowance[from][msg.sender] -= value;
        _balanceOf[from] -= value;
        _balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    // todo 被approve的账户也可以销毁
    function burn(uint256 value) external {
        _balanceOf[msg.sender] -= value;
        _totalSupply -= value;
        emit Transfer(msg.sender, address(0), value);
    }
}