AGENTIC_IDES_LIST=(
    "OpenCode|install_opencode|opencode"
    "ZCode|install_zcode|zcode"
    "Antigravity CLI|install_antigravity|agy"
    "Kiro|install_kiro|kiro"
)

show_agentic_ides_menu() {
    _render_menu AGENTIC_IDES_LIST "Agentic IDEs" \
        install_all_agentic_ides check_agentic_ides_installations show_main_menu
}

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

install_zcode() {
    if command -v zcode &> /dev/null || [ -d "/opt/zcode" ]; then
        log_message "WARN" "ZCode is already installed."
        return
    fi

    confirm_install "ZCode" "" "Download from z.ai" || return

    case $DISTRO in
        arch)
            install_with_fallback "ZCode" "" "zcode-desktop-bin" "" "zcode"
            return $?
            ;;
        debian)
            log_message "INFO" "Downloading ZCode..."
            local deb_url="https://cdn-zcode.z.ai/zcode/electron/releases/3.2.1/ZCode-3.2.1-linux-x64.deb"
            _verbose_cmd "wget -O /tmp/zcode.deb $deb_url"
            if ! wget --progress=bar:force -O /tmp/zcode.deb "$deb_url"; then
                log_message "ERROR" "Failed to download ZCode"
                rm -f /tmp/zcode.deb
                return 1
            fi
            _verbose_cmd "dpkg -i /tmp/zcode.deb"
            dpkg -i /tmp/zcode.deb || apt install -f -y
            rm -f /tmp/zcode.deb
            ;;
        fedora)
            log_message "INFO" "Downloading ZCode..."
            local rpm_url="https://cdn-zcode.z.ai/zcode/electron/releases/3.2.1/ZCode-3.2.1-linux-x64.rpm"
            _verbose_cmd "wget -O /tmp/zcode.rpm $rpm_url"
            if ! wget --progress=bar:force -O /tmp/zcode.rpm "$rpm_url"; then
                log_message "ERROR" "Failed to download ZCode"
                rm -f /tmp/zcode.rpm
                return 1
            fi
            _verbose_cmd "dnf install -y /tmp/zcode.rpm"
            dnf install -y /tmp/zcode.rpm
            rm -f /tmp/zcode.rpm
            ;;
    esac
    log_message "SUCCESS" "ZCode installed."
}

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

install_kiro() {
    if command -v kiro &> /dev/null || [ -d "/opt/kiro" ]; then
        log_message "WARN" "Kiro is already installed."
        return
    fi

    confirm_install "Kiro" "" "Download from kiro.dev" || return

    case $DISTRO in
        arch)
            install_with_fallback "Kiro" "" "kiro-ide" "" "kiro"
            return $?
            ;;
        debian)
            log_message "INFO" "Downloading Kiro..."
            local deb_url="https://prod.download.desktop.kiro.dev/releases/stable/linux-x64/signed/1.0.89/deb/kiro-ide-1.0.89-stable-linux-x64.deb"
            _verbose_cmd "wget -O /tmp/kiro.deb $deb_url"
            if ! wget --progress=bar:force -O /tmp/kiro.deb "$deb_url"; then
                log_message "ERROR" "Failed to download Kiro"
                rm -f /tmp/kiro.deb
                return 1
            fi
            _verbose_cmd "dpkg -i /tmp/kiro.deb || apt install -f -y"
            dpkg -i /tmp/kiro.deb || apt install -f -y
            rm -f /tmp/kiro.deb
            ;;
        fedora)
            log_message "INFO" "Downloading Kiro..."
            local rpm_url="https://prod.download.desktop.kiro.dev/releases/stable/linux-x64/signed/1.0.89/rpm/kiro-ide-1.0.89-stable-linux-x64.rpm"
            _verbose_cmd "wget -O /tmp/kiro.rpm $rpm_url"
            if ! wget --progress=bar:force -O /tmp/kiro.rpm "$rpm_url"; then
                log_message "ERROR" "Failed to download Kiro"
                rm -f /tmp/kiro.rpm
                return 1
            fi
            _verbose_cmd "dnf install -y /tmp/kiro.rpm"
            dnf install -y /tmp/kiro.rpm
            rm -f /tmp/kiro.rpm
            ;;
    esac
    log_message "SUCCESS" "Kiro installed."
}

check_agentic_ides_installations() {
    _check_installations AGENTIC_IDES_LIST \
        "OpenCode:opencode" "ZCode:zcode" "Antigravity CLI:agy" "Kiro:kiro"
}

install_all_agentic_ides() { _install_list "Agentic IDEs" AGENTIC_IDES_LIST; }
