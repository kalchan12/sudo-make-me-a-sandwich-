# id: masscan
# name: Scanning
# desc: Fast port scanner.
# method: go
# pkg: masscan
# tags: security,network

install_masscan() {
    if command -v masscan &> /dev/null; then
        log_message "WARN" "masscan is already installed."
        return
    fi
    confirm_install "masscan" "masscan" || return
    install_with_fallback "masscan" "masscan" "masscan" "" "masscan"
    _verify_install "masscan" masscan
}
