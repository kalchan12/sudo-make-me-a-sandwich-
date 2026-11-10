#!/usr/bin/env bash
# id: fd
# name: fd
# desc: Fast file finder.
# method: apt
# pkg: fd-find
# tags: cli,search

install_fd() {
    if command -v fd &> /dev/null || command -v fdfind &> /dev/null; then
        log_message "WARN" "fd is already installed."
        return
    fi
    confirm_install "fd" "fd" || return
    install_with_fallback "fd" "fd-find" "fd" "" "fd"
    log_version "fd" "fd-find" "fd"
}
