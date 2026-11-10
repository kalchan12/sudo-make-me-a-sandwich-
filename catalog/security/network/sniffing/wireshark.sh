# id: wireshark
# name: Sniffing
# desc: Packet analyzer.
# method: apt
# pkg: wireshark
# tags: security,network

install_wireshark() {
    if command -v wireshark &> /dev/null || command -v tshark &> /dev/null; then
        log_message "WARN" "wireshark is already installed."
        return
    fi
    confirm_install "wireshark" "wireshark" || return
    install_with_fallback "wireshark" "wireshark" "wireshark" "org.wireshark.Wireshark" "tshark"
    _verify_install "wireshark" tshark
}
