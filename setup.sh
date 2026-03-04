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
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Helper Functions ---

show_banner() {
    clear
    echo -e "${CYAN}"
    echo " ███████╗██╗   ██╗██████╗  ██████╗  ██████╗     ███╗   ███╗ █████╗ ██╗  ██╗███████╗"
    echo " ██╔════╝██║   ██║██╔══██╗██╔═══██╗██╔═══██╗    ████╗ ████║██╔══██╗██║ ██╔╝██╔════╝"
    echo " ███████╗██║   ██║██████╔╝██║   ██║██║   ██║    ██╔████╔██║███████║█████╔╝ ███████╗"
    echo " ╚════██║██║   ██║██╔══██╗██║   ██║██║   ██║    ██║╚██╔╝██║██╔══██║██╔═██╗ ╚════██║"
    echo " ███████║╚██████╔╝██████╔╝╚██████╔╝╚██████╔╝    ██║ ╚═╝ ██║██║  ██║██║  ██╗███████║"
    echo " ╚══════╝ ╚═════╝ ╚═════╝  ╚═════╝  ╚═════╝     ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝"
    echo -e "${NC}"
    echo -e "${PURPLE}  Modular Linux Bootstrapper | Author: psycho${NC}"
    echo " =============================================================================="
    echo ""
}

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

# --- Interactive Menu Functions ---

show_main_menu() {
    echo -e "${YELLOW}Main Menu:${NC}"
    echo "1) Browsers"
    echo "2) Utilities"
    echo "3) IDEs"
    echo "4) Terminals"
    echo "5) Full Installation (All Categories)"
    echo "6) Minimal Installation (Browsers + Terminals)"
    echo "7) Exit"
    echo -n "Select an option: "
    read -r choice
    case $choice in
        1) show_browsers_menu ;;
        2) show_utilities_menu ;;
        3) show_ides_menu ;;
        4) show_terminals_menu ;;
        5) FULL_MODE=true; run_installation ;;
        6) MINIMAL_MODE=true; run_installation ;;
        7) log_message "INFO" "Exiting..."; exit 0 ;;
        *) log_message "WARN" "Invalid option: $choice"; show_main_menu ;;
    esac
}

show_browsers_menu() {
    echo -e "\n${YELLOW}-- Browsers --${NC}"
    echo "1) Install Brave"
    echo "2) Install Google Chrome"
    echo "3) Install Firefox"
    echo "4) Install All Browsers"
    echo "5) Back"
    echo -n "Select option: "
    read -r b_choice
    case $b_choice in
        1) install_brave ;;
        2) install_chrome ;;
        3) install_firefox ;;
        4) install_browsers ;;
        5) show_main_menu ;;
        *) log_message "WARN" "Invalid option"; show_browsers_menu ;;
    esac
    show_main_menu
}

show_utilities_menu() {
    echo -e "\n${YELLOW}-- Utilities --${NC}"
    echo "1) Install Obsidian"
    echo "2) Install WPS Office"
    echo "3) Install All Utilities"
    echo "4) Back"
    echo -n "Select option: "
    read -r u_choice
    case $u_choice in
        1) install_obsidian ;;
        2) install_wps ;;
        3) install_utilities ;;
        4) show_main_menu ;;
        *) log_message "WARN" "Invalid option"; show_utilities_menu ;;
    esac
    show_main_menu
}

show_ides_menu() {
    echo -e "\n${YELLOW}-- IDEs --${NC}"
    echo "1) Install VS Code"
    echo "2) Install Sublime Text"
    echo "3) Install Antigravity IDE"
    echo "4) Install All IDEs"
    echo "5) Back"
    echo -n "Select option: "
    read -r i_choice
    case $i_choice in
        1) install_vscode ;;
        2) install_sublime ;;
        3) install_antigravity ;;
        4) install_ides ;;
        5) show_main_menu ;;
        *) log_message "WARN" "Invalid option"; show_ides_menu ;;
    esac
    show_main_menu
}

show_terminals_menu() {
    echo -e "\n${YELLOW}-- Terminals --${NC}"
    echo "1) Install Kitty"
    echo "2) Install Alacritty"
    echo "3) Install Tilix"
    echo "4) Install GNOME Terminal"
    echo "5) Install All Terminals"
    echo "6) Back"
    echo -n "Select option: "
    read -r t_choice
    case $t_choice in
        1) apt install -y kitty; log_message "SUCCESS" "Kitty installed." ;;
        2) apt install -y alacritty; log_message "SUCCESS" "Alacritty installed." ;;
        3) apt install -y tilix; log_message "SUCCESS" "Tilix installed." ;;
        4) apt install -y gnome-terminal; log_message "SUCCESS" "GNOME Terminal installed." ;;
        5) install_terminals ;;
        6) show_main_menu ;;
        *) log_message "WARN" "Invalid option"; show_terminals_menu ;;
    esac
    show_main_menu
}

# --- Installation Modules (Expanded) ---

update_system() {
    log_message "INFO" "Updating package lists and upgrading system..."
    apt update && apt upgrade -y
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
        wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        apt install -y ./google-chrome-stable_current_amd64.deb
        rm google-chrome-stable_current_amd64.deb
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

install_browsers() {
    log_message "INFO" "--- Installing All Browsers ---"
    install_brave
    install_chrome
    install_firefox
}

install_obsidian() {
    log_message "INFO" "Installing Obsidian..."
    log_message "WARN" "Obsidian installation placeholder (consider Flatpak: flatpak install flathub md.obsidian.Obsidian)"
}

install_wps() {
    log_message "INFO" "WPS Office installation placeholder (via .deb from official site)"
}

install_utilities() {
    log_message "INFO" "--- Installing Utilities ---"
    install_obsidian
    install_wps
}

install_vscode() {
    if ! is_installed code; then
        add_keyring "https://packages.microsoft.com/keys/microsoft.asc" \
                    "/usr/share/keyrings/packages.microsoft.gpg" \
                    "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
                    "vscode"
        apt update && apt install -y code
        log_message "SUCCESS" "VS Code installed."
    fi
}

install_sublime() {
    if ! is_installed sublime-text; then
        add_keyring "https://download.sublimetext.com/sublimehq-pub.gpg" \
                    "/usr/share/keyrings/sublimehq-archive-keyring.gpg" \
                    "deb [signed-by=/usr/share/keyrings/sublimehq-archive-keyring.gpg] https://download.sublimetext.com/ apt/stable/" \
                    "sublime-text"
        apt update && apt install -y sublime-text
        log_message "SUCCESS" "Sublime Text installed."
    fi
}

install_antigravity() {
    log_message "INFO" "Antigravity IDE: Custom repository logic would go here."
}

install_ides() {
    log_message "INFO" "--- Installing All IDEs ---"
    install_vscode
    install_sublime
    install_antigravity
}

install_terminals() {
    log_message "INFO" "--- Installing All Terminals ---"
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

# --- Execution Logic ---

run_installation() {
    log_message "INFO" "Starting installation..."
    update_system

    if [ "$FULL_MODE" = true ] || [ "$MINIMAL_MODE" = true ]; then
        install_browsers
        install_terminals
    fi

    if [ "$FULL_MODE" = true ]; then
        install_utilities
        install_ides
    fi

    log_message "SUCCESS" "Installation tasks complete! Check $LOG_FILE for details."
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --minimal    Install only Browsers and Terminals"
    echo "  --full       Install everything (Browsers, Utilities, IDEs, Terminals)"
    echo "  --help       Show this help message"
    echo ""
    echo "Run without options for interactive menu."
    exit 0
}

main() {
    check_sudo
    show_banner

    # Check for flags
    if [[ $# -gt 0 ]]; then
        while [[ $# -gt 0 ]]; do
            case $1 in
                --minimal) MINIMAL_MODE=true; shift ;;
                --full)    FULL_MODE=true; shift ;;
                --help)    usage ;;
                *)         log_message "ERROR" "Unknown option: $1"; usage ;;
            esac
        done
        run_installation
    else
        # No flags, enter interactive mode
        show_main_menu
    fi
}

main "$@"
