#!/usr/bin/env bash
# id: scrcpy
# name: scrcpy
# desc: Android device screen mirroring.
# method: apt
# pkg: scrcpy
# tags: app,desktop

install_scrcpy() {
    if command -v scrcpy &> /dev/null; then
        log_message "WARN" "scrcpy is already installed."
        _setup_scrcpy_alias
        return 0
    fi
    confirm_install "scrcpy" "scrcpy" || return
    install_with_fallback "scrcpy" "scrcpy" "scrcpy" "" "scrcpy"
    local ec=$?
    if [ $ec -eq 0 ]; then
        if ! command -v adb &> /dev/null; then
            log_message "INFO" "Installing adb for scrcpy..."
            pkg_install_native "adb" 2>/dev/null || true
        fi
        _setup_scrcpy_alias
    fi
    return $ec
}
