# id: eza
# name: eza
# desc: ls alternative.
# method: apt
# pkg: eza
# tags: cli

install_eza() {
    if command -v eza &> /dev/null; then
        log_message "WARN" "eza is already installed."
        return
    fi
    confirm_install "eza" "eza" || return
    install_with_fallback "eza" "eza" "eza" "io.github.eza-community.eza" "eza"
}
