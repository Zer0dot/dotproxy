// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
// import "forge-std/console2.sol";
import "../src/DotProxy.sol";
import "../src/DotImpl.sol";

contract DotProxyTest is Test {
	DotProxy dotProxy;
	DotImpl dotImpl;

	uint256 constant MAX_CODE_SIZE = 24576;
	uint256 constant MAX_IMMUTABLE_COUNT = uint256(24576 - 45) / 32;
	address constant TEST_ADDR = address(1);

	function setUp() public {
		dotImpl = new DotImpl();
		dotProxy = new DotProxy();
	}

	function testProperImmutables() public {
		bytes32[] memory addrs = new bytes32[](MAX_IMMUTABLE_COUNT);
		for (uint256 i = 0; i < MAX_IMMUTABLE_COUNT; ) {
			addrs[i] = bytes32(uint256(uint160(TEST_ADDR)));
			unchecked {
				++i;
			}
		}
		DotImpl clone = DotImpl(dotProxy.dotClone(address(dotImpl), addrs));
		
		assertTrue(address(clone).code.length == 45 + MAX_IMMUTABLE_COUNT * 32);
		for (uint256 i = 0; i < MAX_IMMUTABLE_COUNT; ) {
			assertEq(clone.getImmutAtAsAddr(i), TEST_ADDR);
			unchecked {
				++i;
			}
		}
	}

	function testBeyondMaxImmutablesSize() public {
		bytes32[] memory addrs = new bytes32[](MAX_IMMUTABLE_COUNT + 1);
		for (uint256 i = 0; i < MAX_IMMUTABLE_COUNT; ) {
			addrs[i] = bytes32(uint256(uint160(TEST_ADDR)));
			unchecked {
				++i;
			}
		}
		address clone = dotProxy.dotClone(TEST_ADDR, addrs);
		assertTrue(clone.code.length > 24576);
	}
}
