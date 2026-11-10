# id: subfinder
# name: Subdomains
# desc: Subdomain discovery.
# method: go
# pkg: subfinder
# tags: security,recon

install_subfinder() {
    if [ "$UNINSTALL_MODE" = true ]; then
        if command -v subfinder &> /dev/null; then
            log_message "INFO" "Removing subfinder..."
            pkg_remove subfinder
            rm -f /usr/local/bin/subfinder
            return 0
        else
            log_message "WARN" "subfinder is not installed."
            return 0
        fi
    fi

    if command -v subfinder &> /dev/null; then
        log_message "WARN" "subfinder is already installed."
        return 0
    fi
    confirm_install "subfinder" "subfinder" || return

    if pkg_is_available "subfinder"; then
        log_message "INFO" "Installing subfinder via package manager..."
        pkg_install_native subfinder
    elif [ "$DISTRO" = "arch" ] && aur_install "subfinder-bin"; then
        :
    elif command -v go &> /dev/null; then
        log_message "INFO" "Installing subfinder via Go..."
        _check_deps "subfinder" git || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
            return 0
        fi
        _verbose_cmd "go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
        go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
        if [ -f "$HOME/go/bin/subfinder" ]; then
            ln -sf "$HOME/go/bin/subfinder" /usr/local/bin/subfinder
        fi
    else
        log_message "INFO" "Downloading pre-compiled subfinder release from GitHub..."
        _check_deps "subfinder" curl unzip || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Download and install subfinder from GitHub releases to /usr/local/bin/subfinder"
            return 0
        fi
        local tag
        tag=$(curl -sI https://github.com/projectdiscovery/subfinder/releases/latest | grep -i "^location:" | sed -E 's/.*tag\/v?([0-9.]+).*/\1/' | tr -d '\r\n')
        tag="${tag:-2.6.8}"
        local zip_url="https://github.com/projectdiscovery/subfinder/releases/download/v${tag}/subfinder_${tag}_linux_amd64.zip"
        if curl -fsSL "$zip_url" -o /tmp/subfinder.zip; then
            unzip -qo /tmp/subfinder.zip subfinder -d /usr/local/bin/
            chmod +x /usr/local/bin/subfinder
            rm -f /tmp/subfinder.zip
        else
            log_message "ERROR" "Failed to download subfinder release from GitHub."
            rm -f /tmp/subfinder.zip
            return 1
        fi
    fi

    _verify_install "subfinder" subfinder
    log_version "subfinder" "subfinder" subfinder
}
