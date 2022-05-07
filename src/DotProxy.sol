// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract DotProxy {
	function dotClone(address implementation, bytes32[] calldata immutables) public returns (address) {
		address instance;
		assembly {
			let len := mul(32, immutables.length)
			// precompute size and reserve 2 bytes for it
			let runSize := add(45, len) // 45 is base runtime code size, 56 - 11 (creation code)
			let ptr := mload(64)
			mstore(ptr, 0x3d61000000000000000000000000000000000000000000000000000000000000)
			mstore(add(ptr, 2), shl(240, runSize))
			mstore(add(ptr, 4), 0x80600b3d3981f3363d3d373d3d3d363d73000000000000000000000000000000)
			mstore(add(ptr, 21), shl(96, implementation))
			mstore(add(ptr, 41), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

			// Copy immutables to memory
			calldatacopy(add(ptr, 56), 100, len)

			instance := create(0, ptr, add(runSize, 11))
		}
		if (instance == address(0)) revert();
		return instance;
	}
}
