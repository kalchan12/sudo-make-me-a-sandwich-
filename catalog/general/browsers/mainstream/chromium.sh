#!/usr/bin/env bash
# id: chromium
# name: Chromium
# desc: Open-source Chromium browser.
# method: apt
# pkg: chromium
# tags: browser,mainstream

install_chromium() {
    if command -v chromium &> /dev/null || command -v chromium-browser &> /dev/null; then
        log_message "WARN" "Chromium is already installed."
        return
    fi

    confirm_install "Chromium" "chromium" || return

    case $DISTRO in
        debian)
            _verbose_cmd "apt install -y -V chromium"
            apt install -y -V chromium || apt install -y -V chromium-browser
            ;;
        arch)
            install_with_fallback "Chromium" "chromium" "chromium" "org.chromium.Chromium" "chromium"
            return $?
            ;;
        fedora)
            install_with_fallback "Chromium" "chromium" "" "org.chromium.Chromium" "chromium"
            return $?
            ;;
    esac
    log_message "SUCCESS" "Chromium installed."
    log_version "Chromium" chromium chromium
}
