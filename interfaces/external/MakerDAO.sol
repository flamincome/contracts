// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

interface IGemLike {
    function approve(address, uint) external;
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function deposit() external payable;
    function withdraw(uint) external;
}

interface IManagerLike {
    function cdpCan(address, uint, address) external view returns (uint);
    function ilks(uint) external view returns (bytes32);
    function owns(uint) external view returns (address);
    function urns(uint) external view returns (address);
    function vat() external view returns (address);
    function open(bytes32, address) external returns (uint);
    function give(uint, address) external;
    function cdpAllow(uint, address, uint) external;
    function urnAllow(address, uint) external;
    function frob(uint, int, int) external;
    function flux(uint, address, uint) external;
    function move(uint, address, uint) external;
    function exit(address, uint, address, uint) external;
    function quit(uint, address) external;
    function enter(address, uint) external;
    function shift(uint, uint) external;
}

interface IVatLike {
    function can(address, address) external view returns (uint);
    function ilks(bytes32) external view returns (uint, uint, uint, uint, uint);
    function dai(address) external view returns (uint);
    function urns(bytes32, address) external view returns (uint, uint);
    function frob(bytes32, address, address, address, int, int) external;
    function hope(address) external;
    function move(address, address, uint) external;
}

interface IGemJoinLike {
    function dec() external returns (uint);
    function gem() external returns (IGemLike);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

interface IGNTJoinLike {
    function bags(address) external view returns (address);
    function make(address) external returns (address);
}

interface IDaiJoinLike {
    function vat() external returns (IVatLike);
    function dai() external returns (IGemLike);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

interface IHopeLike {
    function hope(address) external;
    function nope(address) external;
}

interface IEndLike {
    function fix(bytes32) external view returns (uint);
    function cash(bytes32, uint) external;
    function free(bytes32) external;
    function pack(uint) external;
    function skim(bytes32, address) external;
}

interface IJugLike {
    function drip(bytes32) external returns (uint);
}

interface IPotLike {
    function pie(address) external view returns (uint);
    function drip() external returns (uint);
    function join(uint) external;
    function exit(uint) external;
}

interface ISpotLike {
    function ilks(bytes32) external view returns (address, uint);
}

interface IOSMedianizer {
    function read() external view returns (uint, bool);
    function foresight() external view returns (uint, bool);
}

interface IMedianizer {
    function read() external view returns (bytes32);
    function peek() external view returns (bytes32, bool);
    function poke() external;
    function compute() external view returns (bytes32, bool);
}