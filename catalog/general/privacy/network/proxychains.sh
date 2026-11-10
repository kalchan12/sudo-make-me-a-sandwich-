#!/usr/bin/env bash
# id: proxychains
# name: proxychains
# desc: Proxy chains wrapper.
# method: apt
# pkg: proxychains4
# tags: privacy,network

install_proxychains() {
    if command -v proxychains4 &> /dev/null || command -v proxychains &> /dev/null; then
        log_message "WARN" "proxychains is already installed."
        return
    fi
    confirm_install "proxychains4" "proxychains4" || return
    install_with_fallback "proxychains4" "proxychains4" "proxychains4" "" "proxychains4"
    _verify_install "proxychains4" proxychains4
}
