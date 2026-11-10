# id: brave
# name: Brave
# desc: Privacy-respecting Chromium-based browser with built-in ad and tracker blocking.
# method: apt
# pkg: brave-browser
# tags: browser,privacy,mainstream

install_brave() {
    if command -v brave-browser &> /dev/null; then
        log_message "WARN" "Brave is already installed."
        return
    fi

    confirm_install "Brave" "brave-browser" || return

    case $DISTRO in
        debian)
            add_keyring "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg" \
                        "/usr/share/keyrings/brave-browser-archive-keyring.gpg" \
                        "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
                        "brave-browser-release"
            _verbose_cmd "apt update && apt install -y -V brave-browser"
            apt update && apt install -y -V brave-browser
            ;;
        arch)
            install_with_fallback "Brave" "brave-browser" "brave-bin" "com.brave.Browser" "brave-browser"
            return $?
            ;;
        fedora)
            dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
            add_rpm_keyring "https://brave-browser-rpm-release.s3.brave.com/brave-browser-archive-keyring.gpg"
            _verbose_cmd "dnf install -y brave-browser"
            dnf install -y brave-browser
            ;;
    esac
    log_message "SUCCESS" "Brave installed."
    log_version "Brave" brave-browser
}
