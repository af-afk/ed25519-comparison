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
}

contract Ed25519COMPARISON is Test {
    IEd25519Comparison c;

    function setUp() external {
        vm.createSelectFork("https://rpc.superposition.so");
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
        (bool rc,) = 0xC3E443bE2Cfa4F41a5F5E4978D012847d355b419.call(abi.encode(
            digestA,
            digestB,
            pubKey,
            sigA,
            sigB
        ));
        assert(rc);
    }
}

