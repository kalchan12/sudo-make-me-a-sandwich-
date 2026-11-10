#!/usr/bin/env bash
# id: lazygit
# name: lazygit
# desc: Lazy git.
# method: apt
# pkg: lazygit
# tags: cli,git

install_lazygit() {
    if command -v lazygit &> /dev/null; then
        log_message "WARN" "lazygit is already installed."
        return
    fi
    confirm_install "lazygit" "lazygit" || return
    install_with_fallback "lazygit" "lazygit" "lazygit" "io.github.jesseduffield.lazygit" "lazygit"
}
