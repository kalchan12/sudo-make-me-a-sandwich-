#!/usr/bin/env bash
# id: reaver
# name: Wireless
# desc: WPS attack.
# method: python
# pkg: reaver
# tags: security,wifi

install_reaver() {
    if command -v reaver &> /dev/null; then
        log_message "WARN" "reaver is already installed."
        return
    fi
    confirm_install "reaver" "reaver" || return
    install_with_fallback "reaver" "reaver" "reaver" "" "reaver"
    _verify_install "reaver" reaver
}
