# id: zcode
# name: ZCode
# desc: ZCode AI coding CLI.
# method: url
# pkg: zcode
# tags: dev,ai

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
