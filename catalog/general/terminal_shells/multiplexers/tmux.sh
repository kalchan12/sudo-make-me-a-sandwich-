#!/usr/bin/env bash
# id: tmux
# name: tmux
# desc: Terminal multiplexer.
# method: apt
# pkg: tmux
# tags: terminal,multiplexer

install_tmux() {
    if command -v tmux &> /dev/null; then
        log_message "WARN" "tmux is already installed."
        return
    fi
    confirm_install "tmux" "tmux" || return
    install_with_fallback "tmux" "tmux" "tmux" "" "tmux"
}
