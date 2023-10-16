#!/bin/bash
set -e

if [ "$1" = "--update" ]; then
  shift
  export UPDATE_SYMBOLS=1
  if ! command -v jq >/dev/null; then
    echo "jq is required for --update. Please install jq"
    exit 1
  fi
fi

mkdir -p ".testenv/config/nvim"
mkdir -p ".testenv/data/nvim"
mkdir -p ".testenv/state/nvim"
mkdir -p ".testenv/run/nvim"
mkdir -p ".testenv/cache/nvim"
PLUGINS=".testenv/data/nvim/site/pack/plugins/start"

if [ ! -e "$PLUGINS/plenary.nvim" ]; then
  git clone --depth=1 https://github.com/nvim-lua/plenary.nvim.git "$PLUGINS/plenary.nvim"
else
  (cd "$PLUGINS/plenary.nvim" && git pull)
fi
if [ ! -e "$PLUGINS/nvim-treesitter" ]; then
  git clone --depth=1 https://github.com/nvim-treesitter/nvim-treesitter.git "$PLUGINS/nvim-treesitter"
else
  (cd "$PLUGINS/nvim-treesitter" && git pull)
fi

XDG_CONFIG_HOME=".testenv/config" \
  XDG_DATA_HOME=".testenv/data" \
  XDG_STATE_HOME=".testenv/state" \
  XDG_RUNTIME_DIR=".testenv/run" \
  XDG_CACHE_HOME=".testenv/cache" \
  nvim --headless -u tests/minimal_init.lua \
  -c "TSUpdateSync" \
  -c "PlenaryBustedDirectory ${1-tests} { minimal_init = './tests/minimal_init.lua' }"
echo "Success"
