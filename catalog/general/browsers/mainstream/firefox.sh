#!/usr/bin/env bash
# id: firefox
# name: Firefox
# desc: Mozilla Firefox browser.
# method: apt
# pkg: firefox
# tags: browser,mainstream

install_firefox() {
    if command -v firefox &> /dev/null; then
        log_message "WARN" "Firefox is already installed."
        return
    fi

    confirm_install "Firefox" "firefox" || return
    install_with_fallback "Firefox" "firefox" "firefox" "org.mozilla.firefox" "firefox"
    log_version "Firefox" firefox firefox
}
