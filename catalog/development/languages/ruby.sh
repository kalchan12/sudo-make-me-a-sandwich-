#!/usr/bin/env bash
# id: ruby
# name: Ruby
# desc: Ruby runtime.
# method: apt
# pkg: ruby
# tags: lang

install_ruby() {
    if command -v ruby &> /dev/null; then
        log_message "WARN" "Ruby is already installed."
        return
    fi
    confirm_install "Ruby" "ruby" || return
    pkg_install_native ruby
    log_message "SUCCESS" "Ruby installed."
    log_version "Ruby" ruby
}
