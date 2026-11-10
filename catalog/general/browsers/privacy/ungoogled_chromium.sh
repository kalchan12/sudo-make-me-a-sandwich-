#!/usr/bin/env bash
# id: ungoogled_chromium
# name: Ungoogled Chromium
# desc: Chromium without Google branding or services.
# method: apt
# pkg: ungoogled-chromium
# tags: browser,privacy

install_ungoogled_chromium() {
    if command -v ungoogled-chromium &> /dev/null; then
        log_message "WARN" "Ungoogled Chromium is already installed."
        return
    fi
    if command -v flatpak &> /dev/null && flatpak list | grep -q com.github.Eloston.UngoogledChromium; then
        log_message "WARN" "Ungoogled Chromium is already installed (Flatpak)."
        return
    fi

    confirm_install "Ungoogled Chromium" "ungoogled-chromium" || return

    case $DISTRO in
        debian)
            if apt-cache show ungoogled-chromium &> /dev/null; then
                log_message "INFO" "Installing Ungoogled Chromium via apt..."
                _verbose_cmd "apt install -y -V ungoogled-chromium"
                apt install -y -V ungoogled-chromium
                log_message "SUCCESS" "Ungoogled Chromium installed via apt."
            else
                log_message "INFO" "Installing Ungoogled Chromium via Flatpak..."
                if ! command -v flatpak &> /dev/null; then
                    log_message "INFO" "Flatpak not found. Installing Flatpak..."
                    pkg_install_native flatpak
                    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                fi
                _verbose_cmd "flatpak install -y flathub com.github.Eloston.UngoogledChromium"
                flatpak install -y flathub com.github.Eloston.UngoogledChromium
                ln -sf /var/lib/flatpak/exports/bin/com.github.Eloston.UngoogledChromium /usr/local/bin/ungoogled-chromium
                log_message "SUCCESS" "Ungoogled Chromium installed via Flatpak."
            fi
            ;;
        arch)
            install_with_fallback "Ungoogled Chromium" "" "ungoogled-chromium-git" "com.github.Eloston.UngoogledChromium" "ungoogled-chromium"
            return $?
            ;;
        fedora)
            install_with_fallback "Ungoogled Chromium" "" "" "com.github.Eloston.UngoogledChromium" "ungoogled-chromium"
            return $?
            ;;
    esac
    log_version "Ungoogled Chromium" ungoogled-chromium
}
