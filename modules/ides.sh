#!/bin/bash

IDES_LIST=(
    "VS Code|install_vscode|code"
    "Sublime Text|install_sublime|sublime-text"
    "JetBrains Toolbox|install_jetbrains_toolbox|jetbrains-toolbox"
)

show_ides_menu() {
    _render_menu IDES_LIST "IDEs & Editors" \
        install_ides check_ides_installations show_main_menu
}

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

install_sublime() {
    if command -v subl &> /dev/null; then
        log_message "WARN" "Sublime Text is already installed."
        return
    fi
    confirm_install "Sublime Text" "" "Download from sublimetext.com" || return

    case $DISTRO in
        debian)
            _verbose_cmd "wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /usr/share/keyrings/sublimetext.gpg"
            wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /usr/share/keyrings/sublimetext.gpg
            echo "deb [signed-by=/usr/share/keyrings/sublimetext.gpg] https://download.sublimetext.com/ apt/stable/" > /etc/apt/sources.list.d/sublime-text.list
            _verbose_cmd "apt update && apt install -y -V sublime-text"
            apt update && apt install -y -V sublime-text
            ;;
        arch)
            install_with_fallback "Sublime Text" "sublime-text" "sublime-text-4" "" "subl"
            return $?
            ;;
        fedora)
            _verbose_cmd "wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /usr/share/keyrings/sublimetext.gpg"
            wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /usr/share/keyrings/sublimetext.gpg
            dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
            _verbose_cmd "dnf install -y sublime-text"
            dnf install -y sublime-text
            ;;
    esac
    log_message "SUCCESS" "Sublime Text installed."
    log_version "Sublime Text" subl
}

install_jetbrains_toolbox() {
    if command -v jetbrains-toolbox &> /dev/null || [ -d "/opt/jetbrains-toolbox" ]; then
        log_message "WARN" "JetBrains Toolbox is already installed."
        return
    fi
    confirm_install "JetBrains Toolbox" "" "Download from jetbrains.com" || return

    _verbose_cmd "wget -O /tmp/jetbrains-toolbox.tar.gz https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.4.40621.tar.gz"
    if ! wget --progress=bar:force -O /tmp/jetbrains-toolbox.tar.gz "https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.4.40621.tar.gz"; then
        log_message "ERROR" "Failed to download JetBrains Toolbox"
        rm -f /tmp/jetbrains-toolbox.tar.gz
        return
    fi
    mkdir -p /opt/jetbrains-toolbox
    tar xzf /tmp/jetbrains-toolbox.tar.gz -C /opt/jetbrains-toolbox --strip-components=1
    chmod +x /opt/jetbrains-toolbox/jetbrains-toolbox
    ln -sf /opt/jetbrains-toolbox/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox
    rm -f /tmp/jetbrains-toolbox.tar.gz
    log_message "SUCCESS" "JetBrains Toolbox installed."
}

install_ides() { _install_list "IDEs" IDES_LIST; }

check_ides_installations() {
    _check_installations IDES_LIST \
        "VS Code:code" "Sublime Text:subl" "JetBrains Toolbox:jetbrains-toolbox"
}
