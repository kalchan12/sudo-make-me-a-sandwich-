#!/usr/bin/env bash
# id: caido
# name: Proxies
# desc: Caido proxy.
# method: cargo
# pkg: caido
# tags: security,web

install_caido() {
    if [ "$UNINSTALL_MODE" = true ]; then
        if command -v caido &> /dev/null || [ -d "/opt/caido" ]; then
            log_message "INFO" "Removing Caido..."
            pkg_remove caido
            rm -rf /opt/caido /usr/local/bin/caido /usr/share/applications/caido.desktop
            return 0
        else
            log_message "WARN" "Caido is not installed."
            return 0
        fi
    fi

    if command -v caido &> /dev/null || [ -f "/opt/caido/caido" ]; then
        log_message "WARN" "Caido is already installed."
        return 0
    fi
    confirm_install "caido" "caido" || return

    if pkg_is_available "caido"; then
        log_message "INFO" "Installing Caido via package manager..."
        pkg_install_native caido
    elif [ "$DISTRO" = "arch" ] && aur_install "caido-desktop"; then
        :
    else
        log_message "INFO" "Downloading Caido CLI package..."
        _check_deps "caido" curl tar || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Download Caido CLI and install to /usr/local/bin/caido"
            return 0
        fi

        local tag
        tag=$(curl -sI https://github.com/caido/caido/releases/latest | grep -i "^location:" | sed -E 's/.*tag\/v?([0-9.]+).*/\1/' | tr -d '\r\n')
        tag="${tag:-0.45.0}"
        local tar_url="https://github.com/caido/caido/releases/download/v${tag}/caido-cli-v${tag}-linux-x86_64.tar.gz"

        mkdir -p /opt/caido
        if curl -fsSL "$tar_url" -o /tmp/caido.tar.gz; then
            tar -xzf /tmp/caido.tar.gz -C /opt/caido
            ln -sf /opt/caido/caido /usr/local/bin/caido
            chmod +x /opt/caido/caido
            rm -f /tmp/caido.tar.gz
        else
            log_message "ERROR" "Failed to download Caido release."
            rm -f /tmp/caido.tar.gz
            return 1
        fi
    fi

    _verify_install "caido" caido
    log_version "caido" "caido" caido
}
