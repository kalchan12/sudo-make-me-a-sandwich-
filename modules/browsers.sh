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
    if ! is_installed brave-browser; then
        add_keyring "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg" \
                    "/usr/share/keyrings/brave-browser-archive-keyring.gpg" \
                    "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
                    "brave-browser-release"
        apt update && apt install -y brave-browser
        log_message "SUCCESS" "Brave installed."
    else
        log_message "WARN" "Brave is already installed."
    fi
}

install_chrome() {
    if ! is_installed google-chrome-stable; then
        log_message "INFO" "Installing Google Chrome..."
        wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome.deb
        apt install -y /tmp/google-chrome.deb
        rm -f /tmp/google-chrome.deb
        log_message "SUCCESS" "Google Chrome installed."
    else
        log_message "WARN" "Google Chrome is already installed."
    fi
}

install_firefox() {
    if ! command -v firefox &> /dev/null; then
        log_message "INFO" "Installing Firefox..."
        apt install -y firefox
        log_message "SUCCESS" "Firefox installed."
    else
        log_message "WARN" "Firefox is already installed."
    fi
}

install_vivaldi() {
    if ! is_installed vivaldi-stable; then
        add_keyring "https://repo.vivaldi.com/archive/linux_signing_key.pub" \
                    "/usr/share/keyrings/vivaldi-browser.gpg" \
                    "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=amd64] https://repo.vivaldi.com/archive/deb/ stable main" \
                    "vivaldi"
        apt update && apt install -y vivaldi-stable
        log_message "SUCCESS" "Vivaldi installed."
    else
        log_message "WARN" "Vivaldi is already installed."
    fi
}

install_chromium() {
    if ! is_installed chromium && ! is_installed chromium-browser; then
        log_message "INFO" "Installing Chromium..."
        apt install -y chromium || apt install -y chromium-browser
        log_message "SUCCESS" "Chromium installed."
    else
        log_message "WARN" "Chromium is already installed."
    fi
}

install_firefox_dev() {
    if [ ! -d "/opt/firefox-developer" ]; then
        log_message "INFO" "Installing Firefox Developer Edition..."
        wget -qO /tmp/firefox-dev.tar.bz2 "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US"
        tar xjf /tmp/firefox-dev.tar.bz2 -C /opt/
        mv /opt/firefox /opt/firefox-developer
        rm -f /tmp/firefox-dev.tar.bz2
        
        # Create symlink
        ln -sf /opt/firefox-developer/firefox /usr/local/bin/firefox-dev
        
        # Create Desktop entry
        cat <<EOF > /usr/share/applications/firefox-developer.desktop
[Desktop Entry]
Name=Firefox Developer Edition
Exec=/opt/firefox-developer/firefox %u
Icon=/opt/firefox-developer/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOF
        log_message "SUCCESS" "Firefox Developer Edition installed."
    else
        log_message "WARN" "Firefox Developer Edition is already installed."
    fi
}

install_ungoogled_chromium() {
    if ! command -v ungoogled-chromium &> /dev/null && ! (command -v flatpak &> /dev/null && flatpak list | grep -q com.github.Eloston.UngoogledChromium); then
        log_message "INFO" "Installing Ungoogled Chromium (via Flatpak)..."
        if ! command -v flatpak &> /dev/null; then
            log_message "INFO" "Flatpak not found. Installing Flatpak..."
            apt install -y flatpak
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        fi
        flatpak install -y flathub com.github.Eloston.UngoogledChromium
        
        # Make a symlink to easily run it from terminal
        ln -sf /var/lib/flatpak/exports/bin/com.github.Eloston.UngoogledChromium /usr/local/bin/ungoogled-chromium
        log_message "SUCCESS" "Ungoogled Chromium installed."
    else
        log_message "WARN" "Ungoogled Chromium is already installed."
    fi
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
            install_brave) is_installed brave-browser && installed=true ;;
            install_chrome) is_installed google-chrome-stable && installed=true ;;
            install_firefox) command -v firefox &> /dev/null && installed=true ;;
            install_vivaldi) is_installed vivaldi-stable && installed=true ;;
            install_chromium) (is_installed chromium || is_installed chromium-browser) && installed=true ;;
            install_firefox_dev) [ -d "/opt/firefox-developer" ] && installed=true ;;
            install_ungoogled_chromium)
                if command -v ungoogled-chromium &> /dev/null || (command -v flatpak &> /dev/null && flatpak list | grep -q com.github.Eloston.UngoogledChromium); then
                    installed=true
                fi
                ;;
        esac
        
        if [ "$installed" = true ]; then
            echo -e "${GREEN}[✔] $name is installed.${NC}"
        else
            echo -e "${RED}[✘] $name is NOT installed.${NC}"
        fi
    done
}
