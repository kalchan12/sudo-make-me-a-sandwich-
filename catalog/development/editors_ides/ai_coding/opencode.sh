# id: opencode
# name: OpenCode
# desc: OpenCode AI coding CLI.
# method: script
# pkg: opencode
# tags: dev,ai

install_opencode() {
    if command -v opencode &> /dev/null; then
        log_message "WARN" "OpenCode is already installed."
        return
    fi

    confirm_install "OpenCode" "opencode" || return

    case $DISTRO in
        arch)
            install_with_fallback "OpenCode" "opencode" "opencode-bin" "" "opencode"
            return $?
            ;;
        debian|fedora)
            log_message "INFO" "Installing OpenCode via official install script..."
            _verbose_cmd "curl -fsSL https://opencode.ai/install | bash"
            if ! curl -fsSL https://opencode.ai/install | bash; then
                log_message "ERROR" "Failed to install OpenCode"
                return 1
            fi
            local profile_file
            for f in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
                [ -f "$f" ] && profile_file="$f"
            done
            if [ -n "$profile_file" ] && ! grep -q 'opencode/bin' "$profile_file" 2>/dev/null; then
                echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> "$profile_file"
            fi
            export PATH="$HOME/.opencode/bin:$PATH"
            ;;
    esac
    log_message "SUCCESS" "OpenCode installed."
    log_version "OpenCode" "" opencode
}
