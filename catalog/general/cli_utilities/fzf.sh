#!/usr/bin/env bash
# id: fzf
# name: fzf
# desc: Fuzzy finder.
# method: apt
# pkg: fzf
# tags: cli

install_fzf() {
    if command -v fzf &> /dev/null; then
        log_message "WARN" "fzf is already installed."
        return
    fi
    confirm_install "fzf" "fzf" || return
    install_with_fallback "fzf" "fzf" "fzf" "" "fzf"
}
