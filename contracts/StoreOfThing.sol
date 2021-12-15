//SPDX-License-Identifier: MIT
  
pragma solidity ^0.8.6;

contract StoreOfThing {
    struct Product {
        string name;
        uint256 price;
        address owner;
        uint256 registered;
    }
    struct Thing {
        uint256 id;
        uint256 amount;
    }
    struct Debt {
        uint256 pending;
        uint256 current;
    }
    mapping(uint256 => Product) private _products;
    mapping(address => Thing[]) private _thing;
    mapping(address => mapping(uint256 => uint256)) private _supplies;
    mapping(address => mapping(address => mapping(uint256 => Debt))) private _debts;
    uint256 private _counter;
    bool private _lock;

    modifier ReentrencyGuard() {
        require(_lock == false, "Store of thing: reentrency detected");
        _lock = true;
        _;
        _lock = false;
    }
}

