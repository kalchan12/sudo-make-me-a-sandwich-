#!/usr/bin/env bash
# id: go
# name: Go
# desc: Go runtime.
# method: apt
# pkg: golang
# tags: lang

install_go() {
    if command -v go &> /dev/null; then
        log_message "WARN" "Go is already installed."
        return
    fi
    confirm_install "Go" "golang" || return
    install_with_fallback "Go" "golang" "go" "" "go"
    log_version "Go" golang go
}
