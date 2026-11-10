#!/usr/bin/env bash
# id: vivaldi
# name: Vivaldi
# desc: Chromium-based browser with built-in ad blocker.
# method: apt
# pkg: vivaldi-stable
# tags: browser,mainstream

install_vivaldi() {
    if command -v vivaldi-stable &> /dev/null; then
        log_message "WARN" "Vivaldi is already installed."
        return
    fi

    confirm_install "Vivaldi" "vivaldi-stable" || return

    case $DISTRO in
        debian)
            add_keyring "https://repo.vivaldi.com/archive/linux_signing_key.pub" \
                        "/usr/share/keyrings/vivaldi-browser.gpg" \
                        "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=amd64] https://repo.vivaldi.com/archive/deb/ stable main" \
                        "vivaldi"
            _verbose_cmd "apt update && apt install -y -V vivaldi-stable"
            apt update && apt install -y -V vivaldi-stable
            ;;
        arch)
            install_with_fallback "Vivaldi" "vivaldi" "vivaldi" "com.vivaldi.Vivaldi" "vivaldi-stable"
            return $?
            ;;
        fedora)
            dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo
            _verbose_cmd "dnf install -y vivaldi-stable"
            dnf install -y vivaldi-stable
            ;;
    esac
    log_message "SUCCESS" "Vivaldi installed."
    log_version "Vivaldi" vivaldi-stable
}
