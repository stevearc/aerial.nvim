#!/bin/bash
set -e

nvim --headless --noplugin -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory ${1-tests} { minimal_init = './tests/minimal_init.lua' }"
echo "Success"
