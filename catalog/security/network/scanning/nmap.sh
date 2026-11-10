#!/usr/bin/env bash
# id: nmap
# name: Scanning
# desc: Network port scanner.
# method: apt
# pkg: nmap
# tags: security,network

install_nmap() {
    if command -v nmap &> /dev/null; then
        log_message "WARN" "nmap is already installed."
        return
    fi
    confirm_install "nmap" "nmap" || return
    install_with_fallback "nmap" "nmap" "nmap" "" "nmap"
    _verify_install "nmap" nmap
}
