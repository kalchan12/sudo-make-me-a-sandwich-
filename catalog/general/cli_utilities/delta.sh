#!/usr/bin/env bash
# id: delta
# name: delta
# desc: Git diff viewer.
# method: apt
# pkg: git-delta
# tags: cli,git

install_delta() {
    if command -v delta &> /dev/null; then
        log_message "WARN" "delta is already installed."
        return
    fi
    confirm_install "delta" "git-delta" || return
    install_with_fallback "delta" "git-delta" "git-delta" "" "delta"
}
