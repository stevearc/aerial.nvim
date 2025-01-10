proc fn_1() =
  discard

proc fn_2*() =
  discard

func fn_3() =
  discard

type SHORT = int16

type State* = object
  visited*: bool
  data*: ptr int32


type COORD* {.bycopy.} = object
  X*: SHORT
  Y*: SHORT

var top_level_var = "NONE"

const
  CONST_A = "A"
  CONST_B = "B"

type Options = enum
  Option1
  Option2
