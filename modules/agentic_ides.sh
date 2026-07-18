AGENTIC_IDES_LIST=(
    "OpenCode|install_opencode"
    "ZCode|install_zcode"
    "Antigravity|install_antigravity"
    "Kiro|install_kiro"
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
    if command -v antigravity &> /dev/null || [ -d "/opt/antigravity" ]; then
        log_message "WARN" "Antigravity is already installed."
        return
    fi

    confirm_install "Antigravity" "antigravity" || return

    case $DISTRO in
        debian)
            log_message "INFO" "Installing Antigravity via apt repo..."
            mkdir -p /etc/apt/keyrings
            curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg \
                | gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
            echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" \
                > /etc/apt/sources.list.d/antigravity.list
            _verbose_cmd "apt update && apt install -y -V antigravity"
            apt update && apt install -y -V antigravity
            ;;
        arch|fedora)
            log_message "INFO" "Downloading Antigravity..."
            local tarball_url="https://storage.googleapis.com/antigravity-public/antigravity-hub/2.2.1-5287492581195776/linux-x64/Antigravity.tar.gz"
            _verbose_cmd "wget -O /tmp/antigravity.tar.gz $tarball_url"
            if ! wget --progress=bar:force -O /tmp/antigravity.tar.gz "$tarball_url"; then
                log_message "ERROR" "Failed to download Antigravity"
                rm -f /tmp/antigravity.tar.gz
                return 1
            fi
            mkdir -p /opt/antigravity
            tar xzf /tmp/antigravity.tar.gz -C /opt/antigravity --strip-components=1
            rm -f /tmp/antigravity.tar.gz
            ln -sf /opt/antigravity/antigravity /usr/local/bin/antigravity
            ;;
    esac
    log_message "SUCCESS" "Antigravity installed."
    log_version "Antigravity" "" antigravity
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
        "OpenCode:opencode" "ZCode:zcode" "Antigravity:antigravity" "Kiro:kiro"
}

install_all_agentic_ides() { _install_list "Agentic IDEs" AGENTIC_IDES_LIST; }
