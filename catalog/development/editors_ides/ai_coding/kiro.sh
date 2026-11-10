# id: kiro
# name: Kiro
# desc: Kiro AI coding CLI.
# method: url
# pkg: kiro
# tags: dev,ai

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
