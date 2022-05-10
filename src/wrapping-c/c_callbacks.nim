##[
C Callbacks
===========

Sometimes a C function can be repurposed via macros
created using `#define`.

The following example creates a macro that calls a
function ommiting its callback.

]##

{.emit"""
typedef int CbackFunc (int, int);

// As written in C header files (*.h)
int fn(int a, int b, CbackFunc c);

// As written on the C source files (*.c)
int fn ( int a, int b, CbackFunc c) {
    if (c) return c(a,b);
    else   return a + b;
}

// The function that will be used as callback
int multi( int a, int b ) { return a * b; }
#define sum(a,b) fn(a,b,NULL);
""".}

type
  CbackFunc* = proc (a1: cint; a2: cint): cint {.cdecl.}

proc fn*(a, b: cint, c: CbackFunc): cint {.importc.}

template sum*(a, b: untyped): untyped =
  fn(a, b, nil)

# {.cdecl.} is needed to match the CbackFunc
proc multi* (a: cint, b:cint) : cint {.importc, cdecl.}

assert( fn(10, 20, multi ) == 200 )
assert( sum(10, 20)        ==  30 )
