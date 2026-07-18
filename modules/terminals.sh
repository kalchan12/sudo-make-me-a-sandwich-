#!/bin/bash

TERMINALS_LIST=(
    "Kitty|install_kitty|kitty"
    "Alacritty|install_alacritty|alacritty"
    "Tilix|install_tilix|tilix"
    "GNOME Terminal|install_gnome_terminal|gnome-terminal"
)

show_terminals_menu() {
    _render_menu TERMINALS_LIST "Terminals" \
        install_terminals check_terminals_installations show_main_menu
}

install_kitty() {
    if command -v kitty &> /dev/null; then
        log_message "WARN" "Kitty is already installed."
        return
    fi
    confirm_install "Kitty" "kitty" || return
    install_with_fallback "Kitty" "kitty" "kitty" "org.xfce.kitty" "kitty"
    log_version "Kitty" kitty
}

install_alacritty() {
    if command -v alacritty &> /dev/null; then
        log_message "WARN" "Alacritty is already installed."
        return
    fi
    confirm_install "Alacritty" "alacritty" || return
    install_with_fallback "Alacritty" "alacritty" "alacritty" "org.alacritty.Alacritty" "alacritty"
    log_version "Alacritty" alacritty
}

install_tilix() {
    if command -v tilix &> /dev/null; then
        log_message "WARN" "Tilix is already installed."
        return
    fi
    confirm_install "Tilix" "tilix" || return
    install_with_fallback "Tilix" "tilix" "tilix" "com.gexperts.Tilix" "tilix"
    log_version "Tilix" tilix
}

install_gnome_terminal() {
    if command -v gnome-terminal &> /dev/null; then
        log_message "WARN" "GNOME Terminal is already installed."
        return
    fi
    confirm_install "GNOME Terminal" "gnome-terminal" || return
    install_with_fallback "GNOME Terminal" "gnome-terminal" "gnome-terminal" "" "gnome-terminal"
    log_version "GNOME Terminal" gnome-terminal
}

install_terminals() { _install_list "Terminals" TERMINALS_LIST; }

check_terminals_installations() {
    _check_installations TERMINALS_LIST \
        "Kitty:kitty" "Alacritty:alacritty" "Tilix:tilix" "GNOME Terminal:gnome-terminal"
}
