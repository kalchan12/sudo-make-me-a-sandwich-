#!/bin/bash

PRODUCTIVITY_LIST=(
    "Obsidian|install_obsidian|obsidian"
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
        "Obsidian:obsidian" "WPS Office:wps" "OBS Studio:obs" "ffmpeg:ffmpeg" "yt-dlp:yt-dlp"
}
