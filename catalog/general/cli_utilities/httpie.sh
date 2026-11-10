#!/usr/bin/env bash
# id: httpie
# name: httpie
# desc: HTTP client.
# method: apt
# pkg: httpie
# tags: cli

install_httpie() {
    if command -v http &> /dev/null; then
        log_message "WARN" "httpie is already installed."
        return
    fi
    confirm_install "httpie" "httpie" || return
    install_with_fallback "httpie" "httpie" "httpie" "" "http"
}
