# id: tldr
# name: tldr
# desc: Simplified man pages.
# method: apt
# pkg: tldr
# tags: cli,docs

install_tldr() {
    if command -v tldr &> /dev/null; then
        log_message "WARN" "tldr is already installed."
        return
    fi
    confirm_install "tldr" "tldr" || return
    install_with_fallback "tldr" "tldr" "tldr" "" "tldr"
}
