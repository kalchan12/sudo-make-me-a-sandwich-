#!/bin/bash

# ==============================================================================
# Browsers Module
# ==============================================================================

# List of browsers: "Display Name|Function Name"
BROWSERS_LIST=(
    "Brave|install_brave"
    "Google Chrome|install_chrome"
    "Firefox|install_firefox"
    "Vivaldi|install_vivaldi"
    "Chromium|install_chromium"
    "Firefox Developer Edition|install_firefox_dev"
    "Ungoogled Chromium|install_ungoogled_chromium"
    "LibreWolf|install_librewolf"
)

show_browsers_menu() {
    echo -e "\n${YELLOW}-- Browsers --${NC}"
    
    local i=1
    for browser_info in "${BROWSERS_LIST[@]}"; do
        local name="${browser_info%%|*}"
        echo "$i) Install $name"
        ((i++))
    done
    
    local all_idx=$i
    echo "$all_idx) Install All Browsers"
    
    local check_idx=$((i+1))
    echo "$check_idx) Check Browser Installations"
    
    local back_idx=$((i+2))
    echo "$back_idx) Back"
    
    echo -n "Select option: "
    read -r b_choice
    
    if [[ "$b_choice" -eq "$all_idx" ]]; then
        install_browsers
    elif [[ "$b_choice" -eq "$check_idx" ]]; then
        check_browsers_installations
    elif [[ "$b_choice" -eq "$back_idx" ]]; then
        show_main_menu
        return
    elif [[ "$b_choice" -ge 1 && "$b_choice" -lt "$all_idx" ]]; then
        local selected_info="${BROWSERS_LIST[$((b_choice-1))]}"
        local func_name="${selected_info##*|}"
        $func_name
    else
        log_message "WARN" "Invalid option"
        show_browsers_menu
        return
    fi
    
    show_main_menu
}

install_brave() {
    if command -v brave-browser &> /dev/null; then
        log_message "WARN" "Brave is already installed."
        return
    fi

    confirm_install "Brave" "brave-browser" || return

    case $DISTRO in
        debian)
            add_keyring "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg" \
                        "/usr/share/keyrings/brave-browser-archive-keyring.gpg" \
                        "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
                        "brave-browser-release"
            apt update && apt install -y -V brave-browser
            ;;
        arch)
            install_with_fallback "Brave" "brave-browser" "brave-bin" "com.brave.Browser" "brave-browser"
            return $?
            ;;
    esac
    log_message "SUCCESS" "Brave installed."
    log_version "Brave" brave-browser
}

install_chrome() {
    if command -v google-chrome-stable &> /dev/null; then
        log_message "WARN" "Google Chrome is already installed."
        return
    fi

    confirm_install "Google Chrome" "" "Download from google.com" || return

    case $DISTRO in
        debian)
            log_message "INFO" "Installing Google Chrome..."
            if ! wget --progress=bar:force -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; then
                log_message "ERROR" "Failed to download Google Chrome"
                rm -f /tmp/google-chrome.deb
                return
            fi
            apt install -y -V /tmp/google-chrome.deb
            rm -f /tmp/google-chrome.deb
            ;;
        arch)
            install_with_fallback "Google Chrome" "" "google-chrome" "com.google.Chrome" "google-chrome-stable"
            return $?
            ;;
    esac
    log_message "SUCCESS" "Google Chrome installed."
    log_version "Google Chrome" google-chrome-stable
}

install_firefox() {
    if command -v firefox &> /dev/null; then
        log_message "WARN" "Firefox is already installed."
        return
    fi

    confirm_install "Firefox" "firefox" || return
    install_with_fallback "Firefox" "firefox" "firefox" "org.mozilla.firefox" "firefox"
    log_version "Firefox" firefox firefox
}

install_vivaldi() {
    if command -v vivaldi-stable &> /dev/null; then
        log_message "WARN" "Vivaldi is already installed."
        return
    fi

    confirm_install "Vivaldi" "vivaldi-stable" || return

    case $DISTRO in
        debian)
            add_keyring "https://repo.vivaldi.com/archive/linux_signing_key.pub" \
                        "/usr/share/keyrings/vivaldi-browser.gpg" \
                        "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=amd64] https://repo.vivaldi.com/archive/deb/ stable main" \
                        "vivaldi"
            apt update && apt install -y -V vivaldi-stable
            ;;
        arch)
            install_with_fallback "Vivaldi" "vivaldi" "vivaldi" "com.vivaldi.Vivaldi" "vivaldi-stable"
            return $?
            ;;
    esac
    log_message "SUCCESS" "Vivaldi installed."
    log_version "Vivaldi" vivaldi-stable
}

install_chromium() {
    if command -v chromium &> /dev/null || command -v chromium-browser &> /dev/null; then
        log_message "WARN" "Chromium is already installed."
        return
    fi

    confirm_install "Chromium" "chromium" || return

    case $DISTRO in
        debian)
            apt install -y -V chromium || apt install -y -V chromium-browser
            ;;
        arch)
            install_with_fallback "Chromium" "chromium" "chromium" "org.chromium.Chromium" "chromium"
            return $?
            ;;
    esac
    log_message "SUCCESS" "Chromium installed."
    log_version "Chromium" chromium chromium
}

install_firefox_dev() {
    if [ -d "/opt/firefox-developer" ] && [ -f "/opt/firefox-developer/firefox" ]; then
        log_message "WARN" "Firefox Developer Edition is already installed."
        return
    fi
    if command -v firefox-dev &> /dev/null; then
        log_message "WARN" "Firefox Developer Edition is already installed."
        return
    fi

    confirm_install "Firefox Developer Edition" "" "Download from mozilla.org" || return

    case $DISTRO in
        debian)
            rm -rf /opt/firefox-developer
            log_message "INFO" "Installing Firefox Developer Edition..."
            if ! wget --progress=bar:force -O /tmp/firefox-dev.tar.bz2 "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US"; then
                log_message "ERROR" "Failed to download Firefox Developer Edition"
                rm -f /tmp/firefox-dev.tar.bz2
                return
            fi
            tar xjf /tmp/firefox-dev.tar.bz2 -C /opt/
            mv /opt/firefox /opt/firefox-developer
            rm -f /tmp/firefox-dev.tar.bz2

            ln -sf /opt/firefox-developer/firefox /usr/local/bin/firefox-dev

            cat <<EOF > /usr/share/applications/firefox-developer.desktop
[Desktop Entry]
Name=Firefox Developer Edition
Exec=/opt/firefox-developer/firefox %u
Icon=/opt/firefox-developer/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOF
            ;;
        arch)
            install_with_fallback "Firefox Developer Edition" "" "firefox-developer-edition" "" "firefox-dev"
            return $?
            ;;
    esac
    log_message "SUCCESS" "Firefox Developer Edition installed."
    log_version "Firefox Developer Edition" "" firefox-dev
}

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
                apt install -y -V ungoogled-chromium
                log_message "SUCCESS" "Ungoogled Chromium installed via apt."
            else
                log_message "INFO" "Installing Ungoogled Chromium via Flatpak..."
                if ! command -v flatpak &> /dev/null; then
                    log_message "INFO" "Flatpak not found. Installing Flatpak..."
                    apt install -y -V flatpak
                    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                fi
                flatpak install -y flathub com.github.Eloston.UngoogledChromium
                ln -sf /var/lib/flatpak/exports/bin/com.github.Eloston.UngoogledChromium /usr/local/bin/ungoogled-chromium
                log_message "SUCCESS" "Ungoogled Chromium installed via Flatpak."
            fi
            ;;
        arch)
            install_with_fallback "Ungoogled Chromium" "" "ungoogled-chromium-git" "com.github.Eloston.UngoogledChromium" "ungoogled-chromium"
            return $?
            ;;
    esac
    log_version "Ungoogled Chromium" ungoogled-chromium
}

install_librewolf() {
    if command -v librewolf &> /dev/null; then
        log_message "WARN" "LibreWolf is already installed."
        return
    fi

    confirm_install "LibreWolf" "librewolf" || return

    case $DISTRO in
        debian)
            log_message "INFO" "Installing LibreWolf..."
            ensure_prerequisites
            local keyring_url="https://deb.librewolf.net/keyring.gpg"
            local keyring_path="/usr/share/keyrings/librewolf.gpg"
            curl -fsSL "$keyring_url" | gpg --dearmor -o "$keyring_path"
            echo "deb [arch=amd64 signed-by=$keyring_path] https://deb.librewolf.net $(lsb_release -sc) main" > /etc/apt/sources.list.d/librewolf.list
            apt update && apt install -y -V librewolf
            ;;
        arch)
            install_with_fallback "LibreWolf" "librewolf" "librewolf-bin" "io.gitlab.librewolf-community" "librewolf"
            return $?
            ;;
    esac
    log_message "SUCCESS" "LibreWolf installed."
    log_version "LibreWolf" librewolf
}

install_browsers() {
    log_message "INFO" "--- Installing All Browsers ---"
    for browser_info in "${BROWSERS_LIST[@]}"; do
        local func_name="${browser_info##*|}"
        $func_name
    done
}

check_browsers_installations() {
    log_message "INFO" "--- Checking Browser Installations ---"
    for browser_info in "${BROWSERS_LIST[@]}"; do
        local name="${browser_info%%|*}"
        local func_name="${browser_info##*|}"
        
        local installed=false
        case $func_name in
            install_brave) command -v brave-browser &> /dev/null && installed=true ;;
            install_chrome) command -v google-chrome-stable &> /dev/null && installed=true ;;
            install_firefox) command -v firefox &> /dev/null && installed=true ;;
            install_vivaldi) command -v vivaldi-stable &> /dev/null && installed=true ;;
            install_chromium) ( command -v chromium &> /dev/null || command -v chromium-browser &> /dev/null ) && installed=true ;;
            install_firefox_dev) ( [ -d "/opt/firefox-developer" ] || command -v firefox-dev &> /dev/null ) && installed=true ;;
            install_ungoogled_chromium)
                if command -v ungoogled-chromium &> /dev/null || (command -v flatpak &> /dev/null && flatpak list | grep -q com.github.Eloston.UngoogledChromium); then
                    installed=true
                fi
                ;;
            install_librewolf) command -v librewolf &> /dev/null && installed=true ;;
        esac
        
        if [ "$installed" = true ]; then
            echo -e "${GREEN}[✔] $name is installed.${NC}"
        else
            echo -e "${RED}[✘] $name is NOT installed.${NC}"
        fi
    done
}
