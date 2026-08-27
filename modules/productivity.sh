#!/bin/bash

PRODUCTIVITY_LIST=(
    "Obsidian|install_obsidian|obsidian"
    "Telegram|install_telegram|telegram-desktop"
    "Proton Pass|install_proton_pass|proton-pass"
    "Proton VPN|install_proton_vpn|protonvpn"
    "WPS Office|install_wps|wps"
    "OBS Studio|install_obs_studio|obs-studio"
    "ffmpeg|install_ffmpeg|ffmpeg"
    "yt-dlp|install_yt_dlp|yt-dlp"
)

show_productivity_menu() {
    _render_menu PRODUCTIVITY_LIST "Productivity" \
        install_productivity check_productivity_installations show_main_menu
}

install_obsidian() {
    if command -v obsidian &> /dev/null; then
        log_message "WARN" "Obsidian is already installed."
        return
    fi
    confirm_install "Obsidian" "obsidian" || return

    case $DISTRO in
        debian)
            if apt-cache show obsidian &> /dev/null; then
                _verbose_cmd "apt install -y -V obsidian"
                apt install -y -V obsidian
            elif command -v flatpak &> /dev/null; then
                _verbose_cmd "flatpak install -y flathub md.obsidian.Obsidian"
                flatpak install -y flathub md.obsidian.Obsidian
            else
                _check_deps "Obsidian" "curl" "jq" "wget"
                log_message "INFO" "Downloading latest Obsidian .deb..."
                local deb_url
                deb_url=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
                    | jq -r '.assets[] | select(.name | endswith("_amd64.deb")) | .browser_download_url' \
                    | head -1)
                if [ -z "$deb_url" ] || [ "$deb_url" = "null" ]; then
                    log_message "ERROR" "Could not fetch Obsidian .deb URL."
                    return
                fi
                _verbose_cmd "wget -O /tmp/obsidian.deb $deb_url"
                wget --progress=bar:force -O /tmp/obsidian.deb "$deb_url" || {
                    log_message "ERROR" "Failed to download Obsidian .deb."
                    rm -f /tmp/obsidian.deb
                    return
                }
                dpkg -i /tmp/obsidian.deb || apt install -f -y
                rm -f /tmp/obsidian.deb
            fi
            ;;
        arch)
            install_with_fallback "Obsidian" "obsidian" "obsidian" "md.obsidian.Obsidian" "obsidian"
            return $?
            ;;
        fedora)
            install_with_fallback "Obsidian" "" "" "md.obsidian.Obsidian" "obsidian"
            return $?
            ;;
    esac
    log_message "SUCCESS" "Obsidian installed."
    log_version "Obsidian" obsidian
}

install_telegram() {
    if command -v telegram-desktop &> /dev/null; then
        log_message "WARN" "Telegram is already installed."
        return
    fi
    confirm_install "Telegram" "telegram-desktop" || return
    install_with_fallback "Telegram" "telegram-desktop" "telegram-desktop" "org.telegram.desktop" "telegram-desktop"
    log_version "Telegram" telegram-desktop
}

install_proton_pass() {
    if command -v proton-pass &> /dev/null || command -v protonpass &> /dev/null; then
        log_message "WARN" "Proton Pass is already installed."
        return
    fi
    confirm_install "Proton Pass" "" || return

    case $DISTRO in
        debian)
            if command -v flatpak &> /dev/null; then
                _flatpak_install "Proton Pass" "me.proton.Pass" "proton-pass"
            else
                _check_deps "Proton Pass" "curl" "wget"
                log_message "INFO" "Downloading latest Proton Pass .deb..."
                if wget --progress=bar:force -O /tmp/ProtonPass.deb "https://proton.me/download/pass/ProtonPass.deb"; then
                    dpkg -i /tmp/ProtonPass.deb || apt install -f -y
                    rm -f /tmp/ProtonPass.deb
                    log_message "SUCCESS" "Proton Pass installed via .deb."
                else
                    log_message "INFO" "Fallback to Flatpak for Proton Pass..."
                    install_with_fallback "Proton Pass" "" "" "me.proton.Pass" "proton-pass"
                fi
            fi
            ;;
        arch)
            install_with_fallback "Proton Pass" "" "proton-pass-bin" "me.proton.Pass" "proton-pass"
            return $?
            ;;
        fedora)
            _check_deps "Proton Pass" "curl" "wget"
            log_message "INFO" "Downloading latest Proton Pass .rpm..."
            if wget --progress=bar:force -O /tmp/ProtonPass.rpm "https://proton.me/download/pass/ProtonPass.rpm"; then
                dnf install -y /tmp/ProtonPass.rpm
                rm -f /tmp/ProtonPass.rpm
                log_message "SUCCESS" "Proton Pass installed via .rpm."
            else
                install_with_fallback "Proton Pass" "" "" "me.proton.Pass" "proton-pass"
            fi
            ;;
    esac
    log_version "Proton Pass" "" "proton-pass"
}

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

install_obs_studio() {
    if command -v obs &> /dev/null; then
        log_message "WARN" "OBS Studio is already installed."
        return
    fi
    confirm_install "OBS Studio" "obs-studio" || return
    case $DISTRO in
        debian)
            _check_deps "OBS Studio (recommended)" "libavcodec-extra"
            ;;
    esac
    install_with_fallback "OBS Studio" "obs-studio" "obs-studio" "com.obsproject.Studio" "obs"
    log_version "OBS Studio" obs
}

install_ffmpeg() {
    if command -v ffmpeg &> /dev/null; then
        log_message "WARN" "ffmpeg is already installed."
        return
    fi
    confirm_install "ffmpeg" "ffmpeg" || return
    install_with_fallback "ffmpeg" "ffmpeg" "ffmpeg" "org.ffmpeg.ffmpeg" "ffmpeg"
    log_version "ffmpeg" ffmpeg
}

install_yt_dlp() {
    if command -v yt-dlp &> /dev/null; then
        log_message "WARN" "yt-dlp is already installed."
        return
    fi
    confirm_install "yt-dlp" "yt-dlp" || return
    install_with_fallback "yt-dlp" "yt-dlp" "yt-dlp" "" "yt-dlp"
    log_version "yt-dlp" yt-dlp
}

install_productivity() { _install_list "Productivity" PRODUCTIVITY_LIST; }

check_productivity_installations() {
    _check_installations PRODUCTIVITY_LIST \
        "Obsidian:obsidian" "Telegram:telegram-desktop" "Proton Pass:proton-pass" "Proton VPN:protonvpn-app" "WPS Office:wps" "OBS Studio:obs" "ffmpeg:ffmpeg" "yt-dlp:yt-dlp"
}
