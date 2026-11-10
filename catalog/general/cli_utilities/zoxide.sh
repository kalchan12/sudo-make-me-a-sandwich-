# id: zoxide
# name: zoxide
# desc: Smart cd wrapper.
# method: apt
# pkg: zoxide
# tags: cli

install_zoxide() {
    if command -v zoxide &> /dev/null; then
        log_message "WARN" "zoxide is already installed."
        return
    fi
    confirm_install "zoxide" "zoxide" || return
    install_with_fallback "zoxide" "zoxide" "zoxide" "" "zoxide"
}
