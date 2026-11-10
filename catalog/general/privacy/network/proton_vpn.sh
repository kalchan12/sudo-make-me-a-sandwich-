# id: proton_vpn
# name: Proton VPN
# desc: Proton VPN client.
# method: apt
# pkg: proton-vpn-gnome-desktop
# tags: privacy,network

install_proton_vpn() {
    if command -v protonvpn-app &> /dev/null || command -v protonvpn &> /dev/null || command -v proton-vpn-gnome-desktop &> /dev/null; then
        log_message "WARN" "Proton VPN is already installed."
        return
    fi
    confirm_install "Proton VPN" "proton-vpn-gnome-desktop" || return

    case $DISTRO in
        debian)
            _check_deps "Proton VPN" "curl" "wget" "gpg"
            log_message "INFO" "Setting up Proton VPN repository..."
            local deb_repo_url="https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.6_all.deb"
            if wget --progress=bar:force -O /tmp/protonvpn-repo.deb "$deb_repo_url"; then
                dpkg -i /tmp/protonvpn-repo.deb
                rm -f /tmp/protonvpn-repo.deb
                apt update
                apt install -y -V proton-vpn-gnome-desktop || apt install -y -V protonvpn
                log_message "SUCCESS" "Proton VPN installed."
            else
                install_with_fallback "Proton VPN" "proton-vpn-gnome-desktop" "proton-vpn-gtk-app" "com.protonvpn.www" "protonvpn-app"
            fi
            ;;
        arch)
            install_with_fallback "Proton VPN" "" "proton-vpn-gtk-app" "com.protonvpn.www" "protonvpn-app"
            return $?
            ;;
        fedora)
            local fedora_ver
            fedora_ver=$(rpm -E %fedora 2>/dev/null || echo "40")
            local rpm_repo_url="https://repo.protonvpn.com/fedora-${fedora_ver}-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.3-1.noarch.rpm"
            log_message "INFO" "Setting up Proton VPN repository for Fedora..."
            if dnf install -y "$rpm_repo_url"; then
                dnf install -y proton-vpn-gnome-desktop || dnf install -y protonvpn
                log_message "SUCCESS" "Proton VPN installed."
            else
                install_with_fallback "Proton VPN" "proton-vpn-gnome-desktop" "" "com.protonvpn.www" "protonvpn-app"
            fi
            ;;
    esac
    log_version "Proton VPN" "" "protonvpn-app"
}
