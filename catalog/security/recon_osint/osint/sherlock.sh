#!/usr/bin/env bash
# id: sherlock
# name: OSINT
# desc: Username OSINT.
# method: go
# pkg: sherlock
# tags: security,osint

install_sherlock() {
    if command -v sherlock &> /dev/null; then
        log_message "WARN" "sherlock is already installed."
        return
    fi
    confirm_install "sherlock" "sherlock" || return
    log_message "INFO" "sherlock is a Python tool. Checking for pip..."
    _install_with_pip_fallback "sherlock" "sherlock-project" "sherlock"
}
