# id: aircrack
# name: Wireless
# desc: WiFi security suite.
# method: apt
# pkg: aircrack-ng
# tags: security,wifi

install_aircrack() {
    if command -v aircrack-ng &> /dev/null; then
        log_message "WARN" "aircrack-ng is already installed."
        return
    fi
    confirm_install "aircrack-ng" "aircrack-ng" || return
    install_with_fallback "aircrack-ng" "aircrack-ng" "aircrack-ng" "" "aircrack-ng"
    _verify_install "aircrack-ng" aircrack-ng
}
