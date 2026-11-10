# id: tilix
# name: Tilix
# desc: Flexible terminal emulator with splits and tabs.
# method: apt
# pkg: tilix
# tags: terminal

install_tilix() {
    if command -v tilix &> /dev/null; then
        log_message "WARN" "Tilix is already installed."
        return
    fi
    confirm_install "Tilix" "tilix" || return
    install_with_fallback "Tilix" "tilix" "tilix" "com.gexperts.Tilix" "tilix"
    log_version "Tilix" tilix
}
