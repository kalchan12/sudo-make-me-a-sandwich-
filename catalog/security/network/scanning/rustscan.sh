#!/usr/bin/env bash
# id: rustscan
# name: Scanning
# desc: Rust port scanner.
# method: go
# pkg: rustscan
# tags: security,network

install_rustscan() {
    if command -v rustscan &> /dev/null; then
        log_message "WARN" "rustscan is already installed."
        return
    fi
    confirm_install "rustscan" "rustscan" || return
    install_with_fallback "rustscan" "rustscan" "rustscan" "" "rustscan"
    _verify_install "rustscan" rustscan
}
