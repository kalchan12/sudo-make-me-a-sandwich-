#!/usr/bin/env bash
# id: alacritty
# name: Alacritty
# desc: Fast GPU-accelerated terminal emulator.
# method: apt
# pkg: alacritty
# tags: terminal

install_alacritty() {
    if command -v alacritty &> /dev/null; then
        log_message "WARN" "Alacritty is already installed."
        return
    fi
    confirm_install "Alacritty" "alacritty" || return
    install_with_fallback "Alacritty" "alacritty" "alacritty" "org.alacritty.Alacritty" "alacritty"
    log_version "Alacritty" alacritty
}
