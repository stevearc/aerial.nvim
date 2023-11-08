#!/bin/bash
set -e

NVIM_TREESITTER_BRANCH='master'

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
    *)
      set -- "$@" "$arg"
      ;;
  esac
done

mkdir -p ".testenv/config/nvim"
mkdir -p ".testenv/data/nvim"
mkdir -p ".testenv/state/nvim"
mkdir -p ".testenv/run/nvim"
mkdir -p ".testenv/cache/nvim"
PLUGINS=".testenv/data/nvim/site/pack/plugins/start"

if [ ! -e "$PLUGINS/plenary.nvim" ]; then
  git clone --depth=1 https://github.com/nvim-lua/plenary.nvim.git "$PLUGINS/plenary.nvim"
fi
if [ ! -e "$PLUGINS/nvim-treesitter" ]; then
  git clone --depth=1 --no-single-branch https://github.com/nvim-treesitter/nvim-treesitter.git "$PLUGINS/nvim-treesitter"
fi

(cd "$PLUGINS/plenary.nvim" && git pull)
(cd "$PLUGINS/nvim-treesitter" && git checkout ${NVIM_TREESITTER_BRANCH} && git pull)

export XDG_CONFIG_HOME=".testenv/config"
export XDG_DATA_HOME=".testenv/data"
export XDG_STATE_HOME=".testenv/state"
export XDG_RUNTIME_DIR=".testenv/run"
export XDG_CACHE_HOME=".testenv/cache"

nvim --headless -u tests/minimal_init.lua \
  -c "RunTests ${1-tests}"
echo "Success"
