# id: rust
# name: Rust
# desc: Rust runtime.
# method: apt
# pkg: rust
# tags: lang

install_rust() {
    if command -v rustc &> /dev/null; then
        log_message "WARN" "Rust is already installed."
        return
    fi
    confirm_install "Rust" "rust" || return
    if command -v rustup &> /dev/null; then
        rustup install stable
    else
        _verbose_cmd "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        # shellcheck source=dev/null
        . "$HOME/.cargo/env"
    fi
    log_message "SUCCESS" "Rust installed."
    log_version "Rust" rust rustc
}
