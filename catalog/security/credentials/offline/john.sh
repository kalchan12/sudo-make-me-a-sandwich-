# id: john
# name: Offline cracking
# desc: Offline password cracking.
# method: perl
# pkg: john
# tags: security,creds

install_john() {
    if command -v john &> /dev/null; then
        log_message "WARN" "john is already installed."
        return
    fi
    confirm_install "john" "john" || return
    install_with_fallback "john" "john" "john" "" "john"
    _verify_install "john" john
}
