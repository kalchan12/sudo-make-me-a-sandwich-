#!/usr/bin/env bash
# id: nuclei
# name: Scanners
# desc: Template-based vulnerability scanner.
# method: go
# pkg: nuclei
# tags: security,web,bugbounty

install_nuclei() {
    if [ "$UNINSTALL_MODE" = true ]; then
        if command -v nuclei &> /dev/null; then
            log_message "INFO" "Removing nuclei..."
            pkg_remove nuclei
            rm -f /usr/local/bin/nuclei
            return 0
        else
            log_message "WARN" "nuclei is not installed."
            return 0
        fi
    fi

    if command -v nuclei &> /dev/null; then
        log_message "WARN" "nuclei is already installed."
        return 0
    fi
    confirm_install "nuclei" "nuclei" || return

    if pkg_is_available "nuclei"; then
        log_message "INFO" "Installing nuclei via package manager..."
        pkg_install_native nuclei
    elif [ "$DISTRO" = "arch" ] && aur_install "nuclei-bin"; then
        :
    elif command -v go &> /dev/null; then
        log_message "INFO" "Installing nuclei via Go..."
        _check_deps "nuclei" git || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
            return 0
        fi
        _verbose_cmd "go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
        go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
        if [ -f "$HOME/go/bin/nuclei" ]; then
            ln -sf "$HOME/go/bin/nuclei" /usr/local/bin/nuclei
        fi
    else
        log_message "INFO" "Downloading pre-compiled nuclei release from GitHub..."
        _check_deps "nuclei" curl unzip || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Download and install nuclei from GitHub releases to /usr/local/bin/nuclei"
            return 0
        fi
        local tag
        tag=$(curl -sI https://github.com/projectdiscovery/nuclei/releases/latest | grep -i "^location:" | sed -E 's/.*tag\/v?([0-9.]+).*/\1/' | tr -d '\r\n')
        tag="${tag:-3.3.6}"
        local zip_url="https://github.com/projectdiscovery/nuclei/releases/download/v${tag}/nuclei_${tag}_linux_amd64.zip"
        if curl -fsSL "$zip_url" -o /tmp/nuclei.zip; then
            unzip -qo /tmp/nuclei.zip nuclei -d /usr/local/bin/
            chmod +x /usr/local/bin/nuclei
            rm -f /tmp/nuclei.zip
        else
            log_message "ERROR" "Failed to download nuclei release from GitHub."
            rm -f /tmp/nuclei.zip
            return 1
        fi
    fi

    _verify_install "nuclei" nuclei
    log_version "nuclei" "nuclei" nuclei
}
