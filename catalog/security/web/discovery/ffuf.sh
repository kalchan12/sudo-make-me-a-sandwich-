#!/usr/bin/env bash
# id: ffuf
# name: Discovery
# desc: Web fuzzer.
# method: go
# pkg: ffuf
# tags: security,web

install_ffuf() {
    if command -v ffuf &> /dev/null; then
        log_message "WARN" "ffuf is already installed."
        return
    fi
    confirm_install "ffuf" "ffuf" || return
    install_with_fallback "ffuf" "ffuf" "ffuf" "" "ffuf"
    _verify_install "ffuf" ffuf
}
