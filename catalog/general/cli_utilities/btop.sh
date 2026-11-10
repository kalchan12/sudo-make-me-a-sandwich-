#!/usr/bin/env bash
# id: btop
# name: btop
# desc: Resource usage monitor.
# method: apt
# pkg: btop
# tags: cli,monitor

install_btop() {
    if command -v btop &> /dev/null; then
        log_message "WARN" "btop is already installed."
        return
    fi
    confirm_install "btop" "btop" || return
    install_with_fallback "btop" "btop" "btop" "net.btop.btop" "btop"
}
