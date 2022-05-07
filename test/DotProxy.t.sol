// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/DotProxy.sol";
import "../src/DotImpl.sol";

contract DotProxyTest is Test {
	DotProxy dotProxy;
	DotImpl dotImpl;

	address testAddr = address(1);

	function setUp() public {
		dotImpl = new DotImpl();
		dotProxy = new DotProxy();
	}

	function testProperImmutables() public {
		// uint256 maxImmutables = uint256(24576 - 45) / 32;
		// vm.assume(immutableCount == maxImmutables);
		uint256 immutableCount = uint256(24576 - 45) / 32 + 10;
		bytes32[] memory addrs = new bytes32[](immutableCount);
		for (uint256 i = 0; i < immutableCount; ) {
			addrs[i] = bytes32(uint256(uint160(testAddr)));
			unchecked {
				++i;
			}
		}
		DotImpl clone = DotImpl(dotProxy.dotClone(address(dotImpl), addrs));
		console2.log(address(clone).code.length);
		for (uint256 i = 0; i < immutableCount; ) {
			assertEq(clone.getImmutAtAsAddr(i), testAddr);
			unchecked {
				++i;
			}
		}
	}
}
