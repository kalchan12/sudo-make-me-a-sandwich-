# id: nikto
# name: Scanners
# desc: Web vulnerability scanner.
# method: perl
# pkg: nikto
# tags: security,web

install_nikto() {
    if command -v nikto &> /dev/null; then
        log_message "WARN" "nikto is already installed."
        return
    fi
    confirm_install "nikto" "nikto" || return
    install_with_fallback "nikto" "nikto" "nikto" "" "nikto"
    _verify_install "nikto" nikto
}
