#!/usr/bin/env bash
# id: glances
# name: glances
# desc: System monitor.
# method: apt
# pkg: glances
# tags: cli,monitor

install_glances() {
    if command -v glances &> /dev/null; then
        log_message "WARN" "glances is already installed."
        return
    fi
    confirm_install "glances" "glances" || return
    install_with_fallback "glances" "glances" "glances" "" "glances"
}
