#!/usr/bin/env bash
# id: tor
# name: Tor
# desc: Tor anonymizer.
# method: apt
# pkg: tor
# tags: privacy,network

install_tor() {
    if command -v tor &> /dev/null; then
        log_message "WARN" "tor is already installed."
        return
    fi
    confirm_install "tor" "tor" || return
    install_with_fallback "tor" "tor" "tor" "" "tor"
    _verify_install "tor" tor
}
