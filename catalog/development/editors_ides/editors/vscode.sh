#!/usr/bin/env bash
# id: vscode
# name: VS Code
# desc: Visual Studio Code editor.
# method: url
# pkg: code
# tags: dev,editor

install_vscode() {
    if command -v code &> /dev/null; then
        log_message "WARN" "VS Code is already installed."
        return
    fi
    confirm_install "VS Code" "" "Download from code.visualstudio.com" || return

    case $DISTRO in
        debian)
            _verbose_cmd "wget -O /tmp/code.deb https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
            if ! wget --progress=bar:force -O /tmp/code.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"; then
                log_message "ERROR" "Failed to download VS Code"
                rm -f /tmp/code.deb
                return
            fi
            _verbose_cmd "apt install -y -V /tmp/code.deb"
            apt install -y -V /tmp/code.deb
            rm -f /tmp/code.deb
            ;;
        arch)
            install_with_fallback "VS Code" "code" "visual-studio-code-bin" "" "code"
            return $?
            ;;
        fedora)
            _verbose_cmd "wget -O /tmp/code.rpm https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
            if ! wget --progress=bar:force -O /tmp/code.rpm "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"; then
                log_message "ERROR" "Failed to download VS Code"
                rm -f /tmp/code.rpm
                return
            fi
            _verbose_cmd "dnf install -y /tmp/code.rpm"
            dnf install -y /tmp/code.rpm
            rm -f /tmp/code.rpm
            ;;
    esac
    log_message "SUCCESS" "VS Code installed."
    log_version "VS Code" code
}
