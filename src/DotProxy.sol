// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

/**
 * Creation code:
 * 61 eeee:	    push2 size (which is runtime code size + immutables length)		    eeee
 * 80:			dup1																eeee, eeee
 * 60 0a: 		push1 offset (in this case, 10, this is the creation code size)		0a, eeee, eeee
 * 3d:			returndatasize														0, 0a, eeee, eeee
 * 39:			codecopy (stack input: memory loc, offset, size)					eeee
 * 3d:			returndatasize														0, eeee
 * f3:			return (stack input: memory offset, size)
 *
 * Runtime code:
 * 36:		    calldatasize														cdsize
 * 3d:		    returndatasize														0, cdsize
 * 3d:		    returndatasize														0, 0, cdsize
 * 37:		    calldatacopy (copy all calldata to memory at slot 0)
 * 3d: 	    	returndatasize														0
 * 3d: 	    	returndatasize														0, 0
 * 3d: 	    	returndatasize														0, 0, 0
 * 36:		    calldatasize														cdsize, 0, 0, 0
 * 3d: 	    	returndatasize														0, cdsize, 0, 0, 0
 * 73 impl:     push20 impl															impl, 0, cdsize, 0, 0, 0
 * 5a:		    gas																	gas, impl, 0, cdsize, 0, 0, 0
 * f4:		    delegatecall (pushes 0 or 1 for success)							succ, 0
 * 3d:		    returndatasize														retsize, succ, 0
 * 82:		    dup3																0, retsize, succ, 0
 * 80:		    dup1																0, 0, retsize, succ, 0
 * 3e:		    returndatacopy (copies all return data w/ our stack)				succ, 0
 * 90:		    swap1																0, succ
 * 3d:		    returndatasize														retsize, 0, succ
 * 91:		    swap2																succ, 0, retsize
 * 60 2b:	    push1 2b (43)														2b, succ, 0, retsize
 * 57:		    jumpi																0, retsize
 * fd:		    revert																rekt (but returns return data)
 * 5b:		    jumpdest															0, retsize
 * f3:		    return
 */
contract DotProxy {
	function dotClone(address implementation, bytes32[] calldata immutables) public returns (address) {
		address instance;
		assembly {
			let len := mul(32, immutables.length)
			// precompute size and reserve 2 bytes for it
			let runSize := add(45, len) // 45 is base runtime code size, 55 - 10 (creation code).
			let ptr := mload(64) // Get the free memory pointer.
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

			// We create the instance, sending 0 ETH, passing the memory pointer and the full code size.
			instance := create(0, ptr, add(runSize, 10))
		}
		if (instance == address(0)) revert();
		return instance;
	}
}
