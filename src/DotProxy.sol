// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

/**
 * @dev This is the creation code opcode breakdown:
 * 3d:			returndatasize														0
 * 61 eeee:	  	push2 size (which is runtime code size + immutables length)			eeee, 0
 * 80:			dup1																eeee, eeee, 0
 * 60 0b: 		push1 offset (in this case, 11, this is the creation code size)		0b, eeee, eeee, 0
 * 3d:			returndatasize														0, 0b, eeee, eeee, 0	
 * 39:			codecopy (stack input: memory loc, offset, size)					eeee, 0
 * 3d:			returndatasize														0, eeee, 0
 * f3:			return (stack input: memory offset, size)							0
 */
contract DotProxy {
	
	function dotClone(address implementation, bytes32[] calldata immutables) public returns (address) {
		address instance;
		assembly {
			let len := mul(32, immutables.length)
			// precompute size and reserve 2 bytes for it
			let runSize := add(45, len) // 45 is base runtime code size, 56 - 11 (creation code)
			let ptr := mload(64) 		// Get the free memory pointer.
			mstore(ptr, 0x3d61000000000000000000000000000000000000000000000000000000000000)
			mstore(add(ptr, 2), shl(240, runSize))
			mstore(add(ptr, 4), 0x80600b3d393df3363d3d373d3d3d363d73000000000000000000000000000000)
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
