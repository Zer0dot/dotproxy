
## Opcode Breakdown (With Stack)

### Creation Code
```
61 eeee:	push2 size (which is runtime code size + immutables length)		    eeee
80:			dup1																eeee, eeee
60 0a: 		push1 offset (in this case, 10, this is the creation code size)		0a, eeee, eeee
3d:			returndatasize														0, 0a, eeee, eeee
39:			codecopy (stack input: memory loc, offset, size)					eeee
3d:			returndatasize														0, eeee
f3:			return (stack input: memory offset, size)							
```

### Runtime Code
```
Runtime
36:		    calldatasize											cdsize
3d:		    returndatasize											0, cdsize
3d:		    returndatasize											0, 0, cdsize
37:		    calldatacopy (copy all calldata to memory at slot 0)
3d: 	    returndatasize											0
3d: 	    returndatasize											0, 0
3d: 	    returndatasize											0, 0, 0
36:		    calldatasize											cdsize, 0, 0, 0
3d: 	    returndatasize											0, cdsize, 0, 0, 0
73 impl:    push20 impl												impl, 0, cdsize, 0, 0, 0
5a:		    gas														gas, impl, 0, cdsize, 0, 0, 0
f4:		    delegatecall (pushes 0 or 1 for success)				succ, 0
3d:		    returndatasize											retsize, succ, 0 
82:		    dup3													0, retsize, succ, 0
80:		    dup1													0, 0, retsize, succ, 0
3e:		    returndatacopy (copies all return data w/ our stack)	succ, 0
90:		    swap1													0, succ
3d:		    returndatasize											retsize, 0, succ
91:		    swap2													succ, 0, retsize
60 2b:	    push1 2b (43)											2b, succ, 0, retsize
57:		    jumpi													0, retsize
fd:		    revert													rekt (but returns return data)
5b:		    jumpdest												0, retsize
f3:		    return													
```