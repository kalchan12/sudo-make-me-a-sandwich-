# id: obsidian
# name: Obsidian
# desc: Markdown notes app.
# method: apt
# pkg: obsidian
# tags: app,notes

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
