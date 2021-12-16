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
    function newProduct(string memory name, uint256 price) public {
        _counter++;
        _products[_counter] = Product({name: name, price: price, owner: msg.sender, registered: block.timestamp});
    }

    function fillProduct(uint256 id, uint256 amount) public {
        require(msg.sender == product(id).owner, "Store of thing: cannot fill product of other user");
        _supplies[msg.sender][id] += amount;
    }

    function buyProduct(uint256 id, uint256 amount) public payable ReentrencyGuard {
        require(supplyOwner(id) >= amount, "Store of thing: supply empty for this product");
        address receiver = product(id).owner;
        _supplies[receiver][id] -= amount;
        _supplies[msg.sender][id] += amount;
        payable(receiver).transfer(product(id).price * amount);
    }

    function thingProduct(uint256 id, uint256 amount) public {
        _things[msg.sender].push(Thing({id: id, amount: amount}));
    }

    function buyThingProduct() public {
        for (uint256 i = 0; i <= _things[msg.sender].length; i++) {
            buyProduct(thingOf(msg.sender, i).id, thingOf(msg.sender, i).amount);
        }
    }

    function exchangeProduct(uint256 id, uint256 amount) public {
        require(supplyOf(msg.sender, id) >= amount, "Store of thing:user supply empty for this product");
        _supplies[msg.sender][id] -= amount;
    }

}

