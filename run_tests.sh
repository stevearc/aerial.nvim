#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

NVIM_TREESITTER_BRANCH='master'
OPEN_NVIM=0

for arg in "$@"; do
  shift
  case "$arg" in
    '--update')
      export UPDATE_SYMBOLS=1
      if ! command -v jq >/dev/null; then
        echo "jq is required for --update. Please install jq"
        exit 1
      fi
      ;;
    '--test-main')
      NVIM_TREESITTER_BRANCH='main'
      ;;
    '--open-nvim')
      OPEN_NVIM=1
      ;;
    *)
      set -- "$@" "$arg"
      ;;
  esac
done

mkdir -p "$SCRIPT_DIR/.testenv/config/nvim"
mkdir -p "$SCRIPT_DIR/.testenv/data/nvim"
mkdir -p "$SCRIPT_DIR/.testenv/state/nvim"
mkdir -p "$SCRIPT_DIR/.testenv/run/nvim"
mkdir -p "$SCRIPT_DIR/.testenv/cache/nvim"
PLUGINS="$SCRIPT_DIR/.testenv/data/nvim/site/pack/plugins/start"

if [ ! -e "$PLUGINS/plenary.nvim" ]; then
  git clone --depth=1 https://github.com/nvim-lua/plenary.nvim.git "$PLUGINS/plenary.nvim"
fi
if [ ! -e "$PLUGINS/nvim-treesitter" ]; then
  git clone --depth=1 --no-single-branch https://github.com/nvim-treesitter/nvim-treesitter.git "$PLUGINS/nvim-treesitter"
fi

if [ ! -e "$PLUGINS/aerial.nvim" ]; then
  ln -s "$SCRIPT_DIR/" "$PLUGINS/aerial.nvim"
fi

(cd "$PLUGINS/plenary.nvim" && git pull)
(cd "$PLUGINS/nvim-treesitter" && git checkout ${NVIM_TREESITTER_BRANCH} && git pull)

export XDG_CONFIG_HOME="$SCRIPT_DIR/.testenv/config"
export XDG_DATA_HOME="$SCRIPT_DIR/.testenv/data"
export XDG_STATE_HOME="$SCRIPT_DIR/.testenv/state"
export XDG_RUNTIME_DIR="$SCRIPT_DIR/.testenv/run"
export XDG_CACHE_HOME="$SCRIPT_DIR/.testenv/cache"

if [[ $OPEN_NVIM -eq 1 ]]; then
  nvim -u tests/minimal_init.lua
else
  nvim --headless -u tests/minimal_init.lua \
  -c "RunTests ${1-tests}"
  echo "Success"
fi
