#!/usr/bin/env bash
# id: r
# name: R
# desc: R runtime.
# method: apt
# pkg: r-base
# tags: lang

install_r() {
    if command -v R &> /dev/null; then
        log_message "WARN" "R is already installed."
        return
    fi
    confirm_install "R" "r-base" || return
    install_with_fallback "R" "r-base" "r" "" "R"
    log_version "R" r-base R
}
