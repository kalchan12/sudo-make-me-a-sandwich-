#!/usr/bin/env bash
# id: neovim
# name: Neovim
# desc: Neovim editor.
# method: apt
# pkg: neovim
# tags: dev,editor

install_neovim() {
    if command -v nvim &> /dev/null; then
        log_message "WARN" "Neovim is already installed."
        return
    fi
    confirm_install "Neovim" "neovim" || return
    install_with_fallback "Neovim" "neovim" "neovim" "io.neovim.nvim" "nvim"
}
