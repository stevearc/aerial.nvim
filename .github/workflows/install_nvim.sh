#!/bin/bash
set -e
PLUGINS="$HOME/.local/share/nvim/site/pack/plugins/start"
mkdir -p "$PLUGINS"

wget "https://github.com/neovim/neovim/releases/download/${NVIM_TAG}/nvim.appimage"
chmod +x nvim.appimage
sudo mv ./nvim.appimage /usr/bin/nvim
