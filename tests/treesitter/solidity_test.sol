// Credit for this file goes to Gonçalo Sá and Federico Bond: https://github.com/ConsenSys/solidity-parser-antlr/commits/master/test/test.sol
// I take part of that file
pragma solidity >=0.5.0 <0.7.0;

library a {
    function f() {
        uint x = 3 < 0 ? 2 > 1 ? 2 : 1 : 7 > 2 ? 7 : 6;
    }
}

contract A {
    bool flag;
    event Log(address indexed sender, string message);

    constructor() public {}

    function m() {
        uint x = 3 < 0 ? 2 > 1 ? 2 : 1 : 7 > 2 ? 7 : 6;
    }

    modifier never() {
        require(false);
        _;
    }
}

interface I {
    function f();
}

struct S {
    uint x;
    uint y;
}

enum E {
    A,
    B,
    C
}
