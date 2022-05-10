##[

Booleans
========

In older C standards there is no boolean type
Its behavior is implemented as an int or char.
Looks odd but have advantages...

As Nim has bool type, and ifs/elses needs the values be
in bool type, we can wonder how to wrap it...
Tested with Nim 1.6.6

]##

# The C snippet
{.emit: """
int id (int a) { return a; }
#define nid(a) (id(a));
""".}

# How wrap in Nim

proc nid (a: cint) : cint  {.importc.}


##[
In C is int, we wrapped as int. Only on use casting to bool
Result: Anything != 0 is true. Behavior not explicitly documented
]##

assert( bool(nid(-1)) == true  )
assert( bool(nid(0) ) == false )
assert( bool(nid(1) ) == true  )
assert( bool(nid(2) ) == true  )


##[
Let the problem for the posterity...
Who use the wrapped C function should decide how it should be evaluated
]##

template boolZeroBased(a) : bool = a != 0
template boolOneBased(a)  : bool = a == 1

assert( boolZeroBased(-1) == true  )
assert( boolZeroBased(0)  == false )
assert( boolZeroBased(1)  == true  )
assert( boolZeroBased(2)  == true  )

assert( boolOneBased(-1)  == false )
assert( boolOneBased(0)   == false )
assert( boolOneBased(1)   == true )
assert( boolOneBased(2)   == false )
