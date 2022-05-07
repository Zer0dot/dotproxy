pragma solidity 0.8.13;

contract DotImpl {
	uint256 constant FIRST_SLOT = 45;

	function getImmutAt(uint256 pos) external view returns (bytes32) {
		address target = address(this);
		bytes32 result;
		assembly {
			let ptr := mload(0x40)
			extcodecopy(target, ptr, add(FIRST_SLOT, mul(32, pos)), 32)
			result := mload(ptr)
		}
		return result;
	}

	function getImmutAtAsAddr(uint256 pos) external view returns (address) {
		address target = address(this);
		address result;
		assembly {
			let ptr := mload(0x40)
			extcodecopy(target, ptr, add(FIRST_SLOT, mul(32, pos)), 32)
			result := mload(ptr)
		}
		return result;
	}

	// This is bad because codecopy copies the implementation code, not the proxy
	function badGetImmutAtAsAddr(uint256 pos) external pure returns (address) {
		address result;
		assembly {
			let ptr := mload(0x40)
			codecopy(ptr, add(FIRST_SLOT, mul(32, pos)), 32)
			result := mload(ptr)
		}
		return result;
	}
}
