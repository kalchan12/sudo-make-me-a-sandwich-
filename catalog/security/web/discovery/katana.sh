# id: katana
# name: Discovery
# desc: Web crawler.
# method: node
# pkg: katana
# tags: security,web

install_katana() {
    if [ "$UNINSTALL_MODE" = true ]; then
        if command -v katana &> /dev/null; then
            log_message "INFO" "Removing katana..."
            pkg_remove katana
            rm -f /usr/local/bin/katana
            return 0
        else
            log_message "WARN" "katana is not installed."
            return 0
        fi
    fi

    if command -v katana &> /dev/null; then
        log_message "WARN" "katana is already installed."
        return 0
    fi
    confirm_install "katana" "katana" || return

    if pkg_is_available "katana"; then
        log_message "INFO" "Installing katana via package manager..."
        pkg_install_native katana
    elif [ "$DISTRO" = "arch" ] && aur_install "katana-bin"; then
        :
    elif command -v go &> /dev/null; then
        log_message "INFO" "Installing katana via Go..."
        _check_deps "katana" git || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} go install -v github.com/projectdiscovery/katana/cmd/katana@latest"
            return 0
        fi
        _verbose_cmd "go install -v github.com/projectdiscovery/katana/cmd/katana@latest"
        go install -v github.com/projectdiscovery/katana/cmd/katana@latest
        if [ -f "$HOME/go/bin/katana" ]; then
            ln -sf "$HOME/go/bin/katana" /usr/local/bin/katana
        fi
    else
        log_message "INFO" "Downloading pre-compiled katana release from GitHub..."
        _check_deps "katana" curl unzip || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Download and install katana from GitHub releases to /usr/local/bin/katana"
            return 0
        fi
        local tag
        tag=$(curl -sI https://github.com/projectdiscovery/katana/releases/latest | grep -i "^location:" | sed -E 's/.*tag\/v?([0-9.]+).*/\1/' | tr -d '\r\n')
        tag="${tag:-1.1.0}"
        local zip_url="https://github.com/projectdiscovery/katana/releases/download/v${tag}/katana_${tag}_linux_amd64.zip"
        if curl -fsSL "$zip_url" -o /tmp/katana.zip; then
            unzip -qo /tmp/katana.zip katana -d /usr/local/bin/
            chmod +x /usr/local/bin/katana
            rm -f /tmp/katana.zip
        else
            log_message "ERROR" "Failed to download katana release from GitHub."
            rm -f /tmp/katana.zip
            return 1
        fi
    fi

    _verify_install "katana" katana
    log_version "katana" "katana" katana
}
