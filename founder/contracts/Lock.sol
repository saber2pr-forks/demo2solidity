// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9; // 版本杂注，指定编译器版本

// Uncomment this line to use console.log
import "hardhat/console.sol"; // 导入语句
// import "hardhat/console.sol" as HConsole; // 命名导入语句1
// import * as HConsole "hardhat/console.sol"; // 命名导入语句2

contract Lock {
    // 1. 变量类型
    uint public unlockTime; // 状态变量 在合约中永久存储，并且强制为 storage 类型（存储中，不是临时变量）

    // 2. 地址类型
    address payable public owner; // 状态变量 在合约中永久存储
    // owner 地址类型，有 balance、transfer、send、call、callcode、delegatecall
    // owner.balance：查询地址的余额
    // owner.transfer：向地址发送以太币
    // owner.call：
    // owner.callcode：
    // owner.delegatecall：


    // 3. 函数修饰器

    //定义修饰器
    modifier modifierfun(uint value){ // 这里的value就是modifierfun(num)传入的num
        require(value >= 10); // 一个内置的校验函数，里面为false的话，会执行报错
        _;  // 代表修饰器所修饰函数中的代码
    }
    // modifierfun 修饰器修饰函数，(先执行修饰器中的代码，再执行函数中的代码)
    // pure 定义这是一个纯函数，没有操作状态变量
    // public 表示公有，可以被外部调用
    // returns(uint) 约束返回值是uint类型
    function setValue(uint num) pure public modifierfun(num) returns(uint) {
        uint a = num;
        return a;
    }

    // 4. 事件
    event Deposit(
        address indexed _from,
        bytes32 indexed _id,
        uint _value
    ); // 定义事件对象内容

    function deposit(bytes32 _id) public payable {
        emit Deposit(msg.sender, _id, msg.value); // 函数内发出event事件
    }
    // 在web端使用web3.js可以监听到这个事件
    // var clientReceipt = web3.eth.contract(abi).at(0x123xxx);
    // var event = clientReceipt.Deposit();
    // event.watch 可以拿到事件发送的值

    // 5. 结构体
    struct Funder {
        address addr;
        uint amount;
    }
    function test() public payable { // 只有 payable 修饰的函数才可以访问 msg.value
        // 实例化一个 Funder 对象，存到内存中
        Funder memory funder = Funder({addr: msg.sender, amount: msg.value});
    }

    event Withdrawal(uint amount, uint when);

    constructor(uint _unlockTime) payable {
        require(
            block.timestamp < _unlockTime,
            "Unlock time should be in the future"
        );

        unlockTime = _unlockTime;
        owner = payable(msg.sender);
    }

    function withdraw() public {
        // Uncomment this line, and the import of "hardhat/console.sol", to print a log in your terminal
        // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

        require(block.timestamp >= unlockTime, "You can't withdraw yet");
        require(msg.sender == owner, "You aren't the owner");

        emit Withdrawal(address(this).balance, block.timestamp);

        owner.transfer(address(this).balance);
    }
}
