##[

Structures
==========

]##

{.emit:"""
struct StructTest {
    size_t someint;
    char somestr[50];
};

// The arrow `->` is used to get a member of the struct
#define structTest_someint(st) ((st)->someint)
#define structTest_somestr(st) ((st)->somestr)
""".}

type
  StructTest = object
    someint : csize_t
    somestr : cstring


template StructTest_someint(st) : csize_t = st.someint
template StructTest_somestr(st) : cstring = st.somestr

var x : StructTest = StructTest(someint: 10, somestr:"hello world")
let y : StructTest = StructTest(someint: 20, somestr:"world hello")

assert( StructTest_someint(x) == 10 )
assert( StructTest_somestr(x) == "hello world" )
assert( StructTest_someint(y) == 20 )
assert( StructTest_somestr(y) == "world hello" )
