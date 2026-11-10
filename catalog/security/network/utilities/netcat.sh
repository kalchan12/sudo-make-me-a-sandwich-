# id: netcat
# name: Utilities
# desc: TCP/IP swiss army knife.
# method: apt
# pkg: netcat-openbsd
# tags: security,network

install_netcat() {
    if command -v nc &> /dev/null; then
        log_message "WARN" "netcat-openbsd is already installed."
        return
    fi
    confirm_install "netcat-openbsd" "netcat-openbsd" || return
    install_with_fallback "netcat-openbsd" "netcat-openbsd" "gnu-netcat" "" "nc"
    _verify_install "netcat-openbsd" nc
    log_version "netcat-openbsd" "" nc
}
