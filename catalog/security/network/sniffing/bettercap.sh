#!/usr/bin/env bash
# id: bettercap
# name: Sniffing
# desc: MITM framework.
# method: go
# pkg: bettercap
# tags: security,network

install_bettercap() {
    if command -v bettercap &> /dev/null; then
        log_message "WARN" "bettercap is already installed."
        return
    fi
    confirm_install "bettercap" "bettercap" || return
    install_with_fallback "bettercap" "bettercap" "bettercap" "" "bettercap"
    _verify_install "bettercap" bettercap
}
