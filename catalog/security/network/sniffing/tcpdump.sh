#!/usr/bin/env bash
# id: tcpdump
# name: Sniffing
# desc: Packet capture.
# method: apt
# pkg: tcpdump
# tags: security,network

install_tcpdump() {
    if command -v tcpdump &> /dev/null; then
        log_message "WARN" "tcpdump is already installed."
        return
    fi
    confirm_install "tcpdump" "tcpdump" || return
    install_with_fallback "tcpdump" "tcpdump" "tcpdump" "" "tcpdump"
    _verify_install "tcpdump" tcpdump
}
