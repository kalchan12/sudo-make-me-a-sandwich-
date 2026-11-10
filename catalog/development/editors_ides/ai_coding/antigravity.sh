#!/usr/bin/env bash
# id: antigravity
# name: Antigravity CLI
# desc: Antigravity CLI (agy).
# method: url
# pkg: agy
# tags: dev,ai

install_antigravity() {
    if command -v agy &> /dev/null || [ -f "$HOME/.local/bin/agy" ]; then
        log_message "WARN" "Antigravity CLI (agy) is already installed."
        return 0
    fi

    confirm_install "Antigravity CLI" "" "Official installer from antigravity.google" || return

    log_message "INFO" "Installing Antigravity CLI (agy) via official bootstrapper..."
    _verbose_cmd "curl -fsSL https://antigravity.google/cli/install.sh | bash"
    if ! curl -fsSL https://antigravity.google/cli/install.sh | bash; then
        log_message "ERROR" "Failed to install Antigravity CLI"
        return 1
    fi

    # Ensure ~/.local/bin is in PATH in shell config files
    local profile_file
    for f in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile"; do
        [ -f "$f" ] && profile_file="$f"
    done
    if [ -n "$profile_file" ] && ! grep -q '\.local/bin' "$profile_file" 2>/dev/null; then
        # "$HOME" must stay literal so it expands later inside the shell profile
        # shellcheck disable=SC2016
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$profile_file"
    fi
    export PATH="$HOME/.local/bin:$PATH"

    # Create symlink in /usr/local/bin if permitted
    if [ -f "$HOME/.local/bin/agy" ]; then
        if [ -w "/usr/local/bin" ]; then
            ln -sf "$HOME/.local/bin/agy" /usr/local/bin/agy 2>/dev/null || true
        elif command -v sudo &>/dev/null; then
            sudo ln -sf "$HOME/.local/bin/agy" /usr/local/bin/agy 2>/dev/null || true
        fi
    fi

    log_message "SUCCESS" "Antigravity CLI (agy) installed."
    log_version "Antigravity CLI" "" agy
}
