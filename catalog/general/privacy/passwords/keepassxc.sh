# id: keepassxc
# name: KeePassXC
# desc: KeePassXC password manager.
# method: apt
# pkg: keepassxc
# tags: privacy,passwords

install_keepassxc() {
    if command -v keepassxc &> /dev/null; then
        log_message "WARN" "KeePassXC is already installed."
        return
    fi
    confirm_install "KeePassXC" "keepassxc" || return
    install_with_fallback "KeePassXC" "keepassxc" "keepassxc" "org.keepassxc.KeePassXC" "keepassxc"
}
