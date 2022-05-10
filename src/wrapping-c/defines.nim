##[
Template Defines
================

In C defines with parameters are likely (not equal) Nim
templates and macros.

]##
{.emit: """
#import <stdio.h>

void (print_id)(int a) {
  printf(" id: %d ",a);
}

/* #define tprint_ids(a,b) (print_id(a),print_id(b)) */

""".}

block :
  proc print_id (a: cint) : void {.importc.}

  template tprint_ids (a,b ) : void =
    block :
      print_id(a)
      print_id(b)

  tprint_ids(10, 20)
  print_id(10)
