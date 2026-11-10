#!/usr/bin/env bash
# id: gnome_terminal
# name: GNOME Terminal
# desc: GNOME Terminal emulator.
# method: apt
# pkg: gnome-terminal
# tags: terminal

install_gnome_terminal() {
    if command -v gnome-terminal &> /dev/null; then
        log_message "WARN" "GNOME Terminal is already installed."
        return
    fi
    confirm_install "GNOME Terminal" "gnome-terminal" || return
    install_with_fallback "GNOME Terminal" "gnome-terminal" "gnome-terminal" "" "gnome-terminal"
    log_version "GNOME Terminal" gnome-terminal
}
