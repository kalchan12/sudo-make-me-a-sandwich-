# id: tauri
# name: Tauri
# desc: Tauri framework.
# method: cargo
# pkg: tauri
# tags: dev,framework

install_tauri() {
    if command -v cargo &> /dev/null && cargo install --list | grep -q tauri-cli; then
        log_message "WARN" "Tauri CLI is already installed."
        return
    fi

    confirm_install "Tauri" "" "Requires Rust (cargo)" || return

    if ! command -v cargo &> /dev/null; then
        log_message "ERROR" "Rust/cargo is required. Install Rust first."
        return 1
    fi

    log_message "INFO" "Installing Tauri CLI..."
    _verbose_cmd "cargo install tauri-cli"
    if cargo install tauri-cli; then
        log_message "SUCCESS" "Tauri CLI installed."
        log_version "Tauri" "" tauri
    else
        log_message "ERROR" "Failed to install Tauri CLI."
        return 1
    fi
}
