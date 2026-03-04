
#!/bin/bash

# ==============================================================================
#  ███████╗██╗   ██╗██████╗  ██████╗  ██████╗     ███╗   ███╗ █████╗ ██╗  ██╗███████╗
#  ██╔════╝██║   ██║██╔══██╗██╔═══██╗██╔═══██╗    ████╗ ████║██╔══██╗██║ ██╔╝██╔════╝
#  ███████╗██║   ██║██████╔╝██║   ██║██║   ██║    ██╔████╔██║███████║█████╔╝ ███████╗
#  ╚════██║██║   ██║██╔══██╗██║   ██║██║   ██║    ██║╚██╔╝██║██╔══██║██╔═██╗ ╚════██║
#  ███████║╚██████╔╝██████╔╝╚██████╔╝╚██████╔╝    ██║ ╚═╝ ██║██║  ██║██║  ██╗███████║
#  ╚══════╝ ╚═════╝ ╚═════╝  ╚═════╝  ╚═════╝     ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
#
#  Modular Linux Bootstrapper (Debian-based)
#  Author: psycho
#  Repo: https://github.com/kalchan12/sudo-make-me-a-sandwich-
# ==============================================================================

# --- Configuration & Colors ---
LOG_FILE="install.log"
MINIMAL_MODE=false
FULL_MODE=false

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Helper Functions ---

log_message() {
    local TYPE=$1
    local MSG=$2
    local TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    
    case $TYPE in
        "INFO")    echo -e "${BLUE}[INFO]${NC} $MSG" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $MSG" ;;
        "WARN")    echo -e "${YELLOW}[WARN]${NC} $MSG" ;;
        "ERROR")   echo -e "${RED}[ERROR]${NC} $MSG" ;;
    esac
    
    echo "[$TIMESTAMP] [$TYPE] $MSG" >> "$LOG_FILE"
}

check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        log_message "ERROR" "This script must be run with sudo."
        exit 1
    fi
}

is_installed() {
    dpkg -s "$1" &> /dev/null
}

add_keyring() {
    local KEY_URL=$1
    local KEYRING_PATH=$2
    local REPO_LINE=$3
    local LIST_FILE=$4

    log_message "INFO" "Adding repository keys for ${LIST_FILE}..."
    curl -fsSL "$KEY_URL" | gpg --dearmor -o "$KEYRING_PATH"
    echo "$REPO_LINE" > "/etc/apt/sources.list.d/${LIST_FILE}.list"
}

# --- Installation Modules ---

update_system() {
    log_message "INFO" "Updating package lists and upgrading system..."
    apt update && apt upgrade -y
}

install_browsers() {
    log_message "INFO" "--- Installing Browsers ---"

    # Brave
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

    # Chrome
    if ! is_installed google-chrome-stable; then
        log_message "INFO" "Installing Google Chrome..."
        wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        apt install -y ./google-chrome-stable_current_amd64.deb
        rm google-chrome-stable_current_amd64.deb
        log_message "SUCCESS" "Google Chrome installed."
    else
        log_message "WARN" "Google Chrome is already installed."
    fi

    # Firefox
    if ! command -v firefox &> /dev/null; then
        log_message "INFO" "Installing Firefox..."
        apt install -y firefox
        log_message "SUCCESS" "Firefox installed."
    else
        log_message "WARN" "Firefox is already installed."
    fi
}

install_utilities() {
    log_message "INFO" "--- Installing Utilities ---"

    # Obsidian
    if ! is_installed obsidian; then
        log_message "INFO" "Installing Obsidian..."
        # Note: Obsidian doesn't have a standard APT repo, usually installed via Flatpak or .deb
        # Example using .deb (requires fetching latest URL usually)
        log_message "WARN" "Obsidian installation placeholder (consider Flatpak: flatpak install flathub md.obsidian.Obsidian)"
    fi

    # WPS Office
    if ! is_installed wps-office; then
        log_message "INFO" "WPS Office installation placeholder (via .deb from official site)"
    fi
}

install_ides() {
    log_message "INFO" "--- Installing IDEs ---"

    # VS Code
    if ! is_installed code; then
        add_keyring "https://packages.microsoft.com/keys/microsoft.asc" \
                    "/usr/share/keyrings/packages.microsoft.gpg" \
                    "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
                    "vscode"
        apt update && apt install -y code
        log_message "SUCCESS" "VS Code installed."
    fi

    # Sublime Text
    if ! is_installed sublime-text; then
        add_keyring "https://download.sublimetext.com/sublimehq-pub.gpg" \
                    "/usr/share/keyrings/sublimehq-archive-keyring.gpg" \
                    "deb [signed-by=/usr/share/keyrings/sublimehq-archive-keyring.gpg] https://download.sublimetext.com/ apt/stable/" \
                    "sublime-text"
        apt update && apt install -y sublime-text
        log_message "SUCCESS" "Sublime Text installed."
    fi

    # Antigravity IDE (Custom Repo Placeholder)
    log_message "INFO" "Antigravity IDE: Custom repository logic would go here."
}

install_terminals() {
    log_message "INFO" "--- Installing Terminals ---"
    local terminals=("kitty" "alacritty" "tilix" "gnome-terminal")
    for t in "${terminals[@]}"; do
        if ! is_installed "$t"; then
            apt install -y "$t"
            log_message "SUCCESS" "$t installed."
        else
            log_message "WARN" "$t is already installed."
        fi
    done
}

# --- Main Execution ---

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --minimal    Install only Browsers and Terminals"
    echo "  --full       Install everything (Browsers, Utilities, IDEs, Terminals)"
    echo "  --help       Show this help message"
    exit 0
}

main() {
    check_sudo
    
    if [[ $# -eq 0 ]]; then usage; fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            --minimal) MINIMAL_MODE=true; shift ;;
            --full)    FULL_MODE=true; shift ;;
            --help)    usage ;;
            *)         log_message "ERROR" "Unknown option: $1"; usage ;;
        esac
    done

    log_message "INFO" "Starting sudo-make-me-a-sandwich- setup..."
    update_system

    if [ "$FULL_MODE" = true ] || [ "$MINIMAL_MODE" = true ]; then
        install_browsers
        install_terminals
    fi

    if [ "$FULL_MODE" = true ]; then
        install_utilities
        install_ides
    fi

    log_message "SUCCESS" "Setup complete! Check $LOG_FILE for details."
}

main "$@"
