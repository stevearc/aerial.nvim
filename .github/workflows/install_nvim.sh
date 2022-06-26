#!/bin/bash
set -e
PLUGINS="$HOME/.local/share/nvim/site/pack/plugins/start"
mkdir -p "$PLUGINS"

wget "https://github.com/neovim/neovim/releases/download/${NVIM_TAG}/nvim.appimage"
chmod +x nvim.appimage
sudo mv ./nvim.appimage /usr/bin/nvim
git clone --depth=1 https://github.com/nvim-lua/plenary.nvim.git "$PLUGINS/plenary.nvim"
git clone https://github.com/nvim-treesitter/nvim-treesitter.git "$PLUGINS/nvim-treesitter"
