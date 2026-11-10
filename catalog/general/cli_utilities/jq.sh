#!/usr/bin/env bash
# id: jq
# name: jq
# desc: JSON processor.
# method: apt
# pkg: jq
# tags: cli,data

install_jq() {
    if command -v jq &> /dev/null; then
        log_message "WARN" "jq is already installed."
        return
    fi
    confirm_install "jq" "jq" || return
    install_with_fallback "jq" "jq" "jq" "" "jq"
}
