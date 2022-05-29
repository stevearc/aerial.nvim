#!/bin/bash
set -e

nvim --headless --noplugin -u tests/init.lua \
  -c "PlenaryBustedDirectory ${1-tests} { minimal_init = './tests/init.lua' }"
echo "Success"
