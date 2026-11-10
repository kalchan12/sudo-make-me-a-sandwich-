#!/usr/bin/env bash
# id: httpx
# name: Discovery
# desc: HTTP toolkit.
# method: go
# pkg: httpx-toolkit
# tags: security,web

install_httpx() {
    if [ "$UNINSTALL_MODE" = true ]; then
        if command -v httpx &> /dev/null || command -v httpx-toolkit &> /dev/null; then
            log_message "INFO" "Removing httpx..."
            pkg_remove httpx-toolkit httpx
            rm -f /usr/local/bin/httpx
            return 0
        else
            log_message "WARN" "httpx is not installed."
            return 0
        fi
    fi

    if command -v httpx &> /dev/null || command -v httpx-toolkit &> /dev/null; then
        log_message "WARN" "httpx is already installed."
        return 0
    fi
    confirm_install "httpx" "httpx-toolkit" || return

    if pkg_is_available "httpx-toolkit"; then
        log_message "INFO" "Installing httpx-toolkit via package manager..."
        pkg_install_native httpx-toolkit
        if [ -f /usr/bin/httpx-toolkit ] && [ ! -e /usr/local/bin/httpx ]; then
            ln -sf /usr/bin/httpx-toolkit /usr/local/bin/httpx
        fi
    elif pkg_is_available "httpx"; then
        log_message "INFO" "Installing httpx via package manager..."
        pkg_install_native httpx
    elif [ "$DISTRO" = "arch" ] && aur_install "httpx-bin"; then
        :
    elif command -v go &> /dev/null; then
        log_message "INFO" "Installing httpx via Go..."
        _check_deps "httpx" git || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
            return 0
        fi
        _verbose_cmd "go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
        go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
        if [ -f "$HOME/go/bin/httpx" ]; then
            ln -sf "$HOME/go/bin/httpx" /usr/local/bin/httpx
        fi
    else
        log_message "INFO" "Downloading pre-compiled httpx release from GitHub..."
        _check_deps "httpx" curl unzip || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Download and install httpx from GitHub releases to /usr/local/bin/httpx"
            return 0
        fi
        local tag
        tag=$(curl -sI https://github.com/projectdiscovery/httpx/releases/latest | grep -i "^location:" | sed -E 's/.*tag\/v?([0-9.]+).*/\1/' | tr -d '\r\n')
        tag="${tag:-1.6.9}"
        local zip_url="https://github.com/projectdiscovery/httpx/releases/download/v${tag}/httpx_${tag}_linux_amd64.zip"
        if curl -fsSL "$zip_url" -o /tmp/httpx.zip; then
            unzip -qo /tmp/httpx.zip httpx -d /usr/local/bin/
            chmod +x /usr/local/bin/httpx
            rm -f /tmp/httpx.zip
        else
            log_message "ERROR" "Failed to download httpx release from GitHub."
            rm -f /tmp/httpx.zip
            return 1
        fi
    fi

    if command -v httpx &> /dev/null; then
        _verify_install "httpx" httpx
        log_version "httpx" "" httpx
    elif command -v httpx-toolkit &> /dev/null; then
        _verify_install "httpx" httpx-toolkit
        log_version "httpx" "httpx-toolkit" httpx-toolkit
    fi
}
