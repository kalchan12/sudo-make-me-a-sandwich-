# id: bat
# name: bat
# desc: cat with syntax highlighting.
# method: apt
# pkg: bat
# tags: cli

install_bat() {
    if command -v bat &> /dev/null || command -v batcat &> /dev/null; then
        log_message "WARN" "bat is already installed."
        return
    fi
    confirm_install "bat" "bat" || return
    install_with_fallback "bat" "bat" "bat" "" "bat"
}
