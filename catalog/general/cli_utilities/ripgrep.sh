#!/usr/bin/env bash
# id: ripgrep
# name: ripgrep
# desc: Ripgrep fast line search.
# method: apt
# pkg: ripgrep
# tags: cli,search

install_ripgrep() {
    if command -v rg &> /dev/null; then
        log_message "WARN" "ripgrep is already installed."
        return
    fi
    confirm_install "ripgrep" "ripgrep" || return
    install_with_fallback "ripgrep" "ripgrep" "ripgrep" "" "rg"
}
