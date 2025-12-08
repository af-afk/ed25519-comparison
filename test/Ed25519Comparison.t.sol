// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";

import {IArbFoundry} from "./IArbFoundry.sol";

interface IEd25519Comparison {
    function createEd25519(bytes32 key, bytes memory preimage) external pure returns (
        bytes32 digestA,
        bytes32 digestB,
        bytes32 pubKey,
        bytes32 sigA,
        bytes32 sigB
    );

    function testEd25519(
        bytes32 digestA,
        bytes32 digestB,
        bytes32 pubKey,
        bytes32 sigA,
        bytes32 sigB
    ) external pure;
}

contract Ed25519COMPARISON is Test {
    IEd25519Comparison c;

    function setUp() external {
        c = IEd25519Comparison(IArbFoundry(address(vm)).deployStylusCode(
            "ed25519-comparison.wasm"
        ));
    }

    function test_fuzzEd25519(bytes32 key, bytes memory preimage) public {
        // In the Rust code we don't do right truncation, so just assume:
        vm.assume(preimage.length % 32 == 0);
        (
            bytes32 digestA,
            bytes32 digestB,
            bytes32 pubKey,
            bytes32 sigA,
            bytes32 sigB
        ) = c.createEd25519(key, preimage);
        vm.resetGasMetering();
        c.testEd25519(digestA, digestB, pubKey, sigA, sigB);
    }

    function test_fuzzEd25519Broken(
        bytes32 digestA,
        bytes32 digestB,
        bytes32 key,
        bytes32 sigA,
        bytes32 sigB
    ) public {
        try
            c.testEd25519(digestA, digestB, key, sigA, sigB)
        {
            revert("should've panicked");
        } catch {}
    }
}
