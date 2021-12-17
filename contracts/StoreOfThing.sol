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
        require(supplyOf(msg.sender, id) >= amount, "Store of thing : user supply empty for this product");
        _supplies[msg.sender][id] -= amount;
    }

 function giveProduct(
        address account,
        uint256 id,
        uint256 amount
    ) public {
        exchangeProduct(id, amount);
        _supplies[account][id] -= amount;
    }

    function lendProduct(
        address account,
        uint256 id,
        uint256 amount
    ) public {
        _debts[msg.sender][account][id].pending += amount;
    }

    function acceptProduct(address account, uint256 id) public {
        uint256 amount = pendingDebt(account, msg.sender, id);
        require(amount > 0, "Store of thing : account do not have lend this product to user");
        _debts[account][msg.sender][id].current += amount;
        _debts[account][msg.sender][id].pending -= amount;
        giveProduct(account, id, amount);
    }

    function repayProduct(
        address account,
        uint256 id,
        uint256 amount
    ) public {
        giveProduct(account, id, amount);
        _debts[account][msg.sender][id].current -= amount;
    }

    function product(uint256 id) public view returns (Product memory) {
        return _products[id];
    }

    function thingOf(address account, uint256 index) public view returns (thing memory) {
        return _baskets[account][index];
    }

    function supplyOf(address account, uint256 id) public view returns (uint256) {
        return _supplies[account][id];
    }

    function supplyOwner(uint256 id) public view returns (uint256) {
        return _supplies[product(id).owner][id];
    }

    function pendingDebt(
        address lender,
        address borrower,
        uint256 id
    ) public view returns (uint256) {
        return _debts[lender][borrower][id].pending;
    }
}

