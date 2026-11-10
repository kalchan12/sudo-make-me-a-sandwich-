# id: flameshot
# name: Flameshot
# desc: Screenshot tool.
# method: apt
# pkg: flameshot
# tags: app,desktop

install_flameshot() {
    if command -v flameshot &> /dev/null; then
        log_message "WARN" "Flameshot is already installed."
        return
    fi
    confirm_install "Flameshot" "flameshot" || return
    install_with_fallback "Flameshot" "flameshot" "flameshot" "org.flameshot.Flameshot" "flameshot"
}
