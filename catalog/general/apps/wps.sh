# id: wps
# name: WPS Office
# desc: WPS Office suite.
# method: flatpak
# pkg: wps
# tags: app,office

install_wps() {
    if command -v wps &> /dev/null; then
        log_message "WARN" "WPS Office is already installed."
        return
    fi
    confirm_install "WPS Office" "" || return

    case $DISTRO in
        debian)
            if command -v flatpak &> /dev/null; then
                _verbose_cmd "flatpak install -y flathub com.wps.Office"
                flatpak install -y flathub com.wps.Office
            else
                log_message "INFO" "Installing flatpak..."
                pkg_install_native flatpak
                flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                _verbose_cmd "flatpak install -y flathub com.wps.Office"
                flatpak install -y flathub com.wps.Office
            fi
            ;;
        arch)
            install_with_fallback "WPS Office" "" "wps-office" "com.wps.Office" "wps"
            return $?
            ;;
        fedora)
            install_with_fallback "WPS Office" "" "" "com.wps.Office" "wps"
            return $?
            ;;
    esac
    log_message "SUCCESS" "WPS Office installed."
}
