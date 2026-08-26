function(configure_target target)
  ADD_LIBRARY(${target} STATIC target.c)
endfunction()

macro(add_example name)
  add_executable(${name} main.c)
endmacro()

add_library(aerial STATIC aerial.c)
add_custom_target(check COMMAND ctest)
