#!/usr/bin/env bash
# id: kitty
# name: Kitty
# desc: GPU-accelerated terminal emulator with hacker themes.
# method: apt
# pkg: kitty
# tags: terminal,kitty

install_kitty() {
    if ! command -v kitty &> /dev/null; then
        confirm_install "Kitty" "kitty" || return
        install_with_fallback "Kitty" "kitty" "kitty" "org.xfce.kitty" "kitty"
        log_version "Kitty" kitty
    else
        log_message "INFO" "Kitty binary is already installed."
    fi

    local script_root
    script_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    if [ -f "$script_root/kitty-config/install.sh" ]; then
        bash "$script_root/kitty-config/install.sh"
    fi
}
