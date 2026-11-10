#!/usr/bin/env bash
# id: chrome
# name: Google Chrome
# desc: Google Chrome browser.
# method: deb_url
# pkg: google-chrome-stable
# tags: browser,mainstream

install_chrome() {
    if command -v google-chrome-stable &> /dev/null; then
        log_message "WARN" "Google Chrome is already installed."
        return
    fi

    confirm_install "Google Chrome" "" "Download from google.com" || return

    case $DISTRO in
        debian)
            _verbose_cmd "wget -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
            if ! wget --progress=bar:force -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; then
                log_message "ERROR" "Failed to download Google Chrome"
                rm -f /tmp/google-chrome.deb
                return
            fi
            _verbose_cmd "apt install -y -V /tmp/google-chrome.deb"
            apt install -y -V /tmp/google-chrome.deb
            rm -f /tmp/google-chrome.deb
            ;;
        arch)
            install_with_fallback "Google Chrome" "" "google-chrome" "com.google.Chrome" "google-chrome-stable"
            return $?
            ;;
        fedora)
            _verbose_cmd "wget -O /tmp/google-chrome.rpm https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm"
            if ! wget --progress=bar:force -O /tmp/google-chrome.rpm https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm; then
                log_message "ERROR" "Failed to download Google Chrome"
                rm -f /tmp/google-chrome.rpm
                return
            fi
            _verbose_cmd "dnf install -y /tmp/google-chrome.rpm"
            dnf install -y /tmp/google-chrome.rpm
            rm -f /tmp/google-chrome.rpm
            ;;
    esac
    log_message "SUCCESS" "Google Chrome installed."
    log_version "Google Chrome" google-chrome-stable
}
