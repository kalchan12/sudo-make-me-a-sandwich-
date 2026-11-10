#!/usr/bin/env bash
# id: reconng
# name: OSINT
# desc: Recon-ng framework.
# method: go
# pkg: recon-ng
# tags: security,osint

install_reconng() {
    if command -v recon-ng &> /dev/null; then
        log_message "WARN" "recon-ng is already installed."
        return
    fi
    confirm_install "recon-ng" "recon-ng" || return
    log_message "INFO" "recon-ng is a Python tool. Checking for pip..."
    _install_with_pip_fallback "recon-ng" "recon-ng" "recon-ng"
}
