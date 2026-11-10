#!/usr/bin/env bash
# id: gobuster
# name: Discovery
# desc: Web directory fuzzer.
# method: go
# pkg: gobuster
# tags: security,web

install_gobuster() {
    if command -v gobuster &> /dev/null; then
        log_message "WARN" "gobuster is already installed."
        return
    fi
    confirm_install "gobuster" "gobuster" || return
    install_with_fallback "gobuster" "gobuster" "gobuster" "" "gobuster"
    _verify_install "gobuster" gobuster
}
