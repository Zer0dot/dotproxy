// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

/**
 * @dev This is the creation code opcode breakdown:
 * 61 eeee:	  	push2 size (which is runtime code size + immutables length)			eeee
 * 80:			dup1																eeee, eeee
 * 60 0a: 		push1 offset (in this case, 10, this is the creation code size)		0a, eeee, eeee
 * 3d:			returndatasize														0, 0a, eeee, eeee
 * 39:			codecopy (stack input: memory loc, offset, size)					eeee
 * 3d:			returndatasize														0, eeee
 * f3:			return (stack input: memory offset, size)							
 */
contract DotProxy {
	
	function dotClone(address implementation, bytes32[] calldata immutables) public returns (address) {
		address instance;
		assembly {
			let len := mul(32, immutables.length)
			// precompute size and reserve 2 bytes for it
			let runSize := add(45, len) // 45 is base runtime code size, 55 - 10 (creation code)
			let ptr := mload(64) 		// Get the free memory pointer.
			mstore(ptr, 0x6100000000000000000000000000000000000000000000000000000000000000)
			mstore(add(ptr, 1), shl(240, runSize))
			mstore(add(ptr, 3), 0x80600a3d393df3363d3d373d3d3d363d73000000000000000000000000000000)
			mstore(add(ptr, 20), shl(96, implementation))
			mstore(add(ptr, 40), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

			// Copy immutables to memory
			// 100 is the calldata offset:
			//		4 bytes for the selector +
			//		32 bytes for the first parameter (impl address)
			//		32 bytes for the immutables array calldata location offset
			//		32 bytes for the immutables array length 
			calldatacopy(add(ptr, 55), 100, len)

			instance := create(0, ptr, add(runSize, 10))
		}
		if (instance == address(0)) revert();
		return instance;
	}
}
