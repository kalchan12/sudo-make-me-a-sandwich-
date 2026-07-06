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
LOG_FILE="$(cd "$(dirname "$0")" && pwd)/install.log"
MINIMAL_MODE=false
FULL_MODE=false
DRY_RUN=false
YES_MODE=false

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
    if [ "$DRY_RUN" = true ]; then
        log_message "INFO" "[DRY-RUN] Skipping root check."
        return
    fi
    if [[ $EUID -ne 0 ]]; then
        log_message "ERROR" "This script must be run with sudo."
        exit 1
    fi
}

log_version() {
    local display="$1"
    local pkg="$2"
    local bin="${3:-$2}"
    local version=""

    if dpkg -s "$pkg" &>/dev/null; then
        version=$(dpkg -s "$pkg" 2>/dev/null | grep "^Version:" | awk '{print $2}')
    elif command -v "$bin" &>/dev/null; then
        version=$("$bin" --version 2>/dev/null | head -1)
        [ -z "$version" ] && version=$("$bin" -v 2>/dev/null | head -1)
        [ -z "$version" ] && version=$("$bin" version 2>/dev/null | head -1)
    fi

    if [ -n "$version" ]; then
        echo -e "${CYAN}  └─ $display: ${NC}$version"
        log_message "INFO" "$display version: $version"
    fi
}

add_keyring() {
    if [ "$DISTRO" != "debian" ]; then
        return 1
    fi

    local KEY_URL=$1
    local KEYRING_PATH=$2
    local REPO_LINE=$3
    local LIST_FILE=$4

    log_message "INFO" "Adding repository keys for ${LIST_FILE}..."
    if ! curl -fsSL "$KEY_URL" | gpg --dearmor -o "$KEYRING_PATH"; then
        log_message "ERROR" "Failed to download key for ${LIST_FILE}"
        return 1
    fi
    echo "$REPO_LINE" > "/etc/apt/sources.list.d/${LIST_FILE}.list"
}

# --- Core Modules ---
CORE_DIR="$(dirname "$0")/core"
for c in "$CORE_DIR"/*.sh; do
    if [ -f "$c" ]; then
        source "$c"
    fi
done

# --- External Modules ---
MODULES_DIR="$(dirname "$0")/modules"
for m in "$MODULES_DIR"/*.sh; do
    if [ -f "$m" ]; then
        source "$m"
    fi
done

# --- Item Lists for Selection UI ---
# Format: "Display Name|function_call_with_args|pkg_name_for_size"
TERMINALS_LIST=(
    "Kitty|install_single_terminal kitty|kitty"
    "Alacritty|install_single_terminal alacritty|alacritty"
    "Tilix|install_single_terminal tilix|tilix"
    "GNOME Terminal|install_single_terminal gnome-terminal|gnome-terminal"
)

UTILITIES_LIST=(
    "Obsidian|install_obsidian|obsidian"
    "WPS Office|install_wps|"
    "OBS Studio|install_obs_studio|obs-studio"
    "ffmpeg|install_ffmpeg|ffmpeg"
    "yt-dlp|install_yt_dlp|yt-dlp"
)

IDES_LIST=(
    "VS Code|install_vscode|code"
    "Sublime Text|install_sublime|sublime-text"
    "JetBrains Toolbox|install_jetbrains_toolbox|"
)

# --- Interactive Menu Functions ---

show_main_menu() {
    echo -e "${YELLOW}Main Menu:${NC}"
    echo "1) Browsers"
    echo "2) Utilities"
    echo "3) IDEs"
    echo "4) Terminals"
    echo "5) Agentic IDEs"
    echo "6) Full Installation (All Categories)"
    echo "7) Minimal Installation (Browsers + Terminals)"
    echo "8) Exit"
    echo -n "Select an option: "
    read -r choice
    case $choice in
        1) show_browsers_menu ;;
        2) show_utilities_menu ;;
        3) show_ides_menu ;;
        4) show_terminals_menu ;;
        5) show_agentic_ides_menu ;;
        6) FULL_MODE=true; run_installation ;;
        7) MINIMAL_MODE=true; run_installation ;;
        8) log_message "INFO" "Exiting..."; exit 0 ;;
        *) log_message "WARN" "Invalid option: $choice"; show_main_menu ;;
    esac
}

show_utilities_menu() {
    echo -e "\n${YELLOW}-- Utilities --${NC}"
    echo "1) Install Obsidian"
    echo "2) Install WPS Office"
    echo "3) Install OBS Studio"
    echo "4) Install ffmpeg"
    echo "5) Install yt-dlp"
    echo "6) Install All Utilities"
    echo "7) Back"
    echo -n "Select option: "
    read -r u_choice
    case $u_choice in
        1) install_obsidian ;;
        2) install_wps ;;
        3) install_obs_studio ;;
        4) install_ffmpeg ;;
        5) install_yt_dlp ;;
        6) install_utilities ;;
        7) show_main_menu ;;
        *) log_message "WARN" "Invalid option"; show_utilities_menu ;;
    esac
    show_main_menu
}

show_ides_menu() {
    echo -e "\n${YELLOW}-- IDEs --${NC}"
    echo "1) Install VS Code"
    echo "2) Install Sublime Text"
    echo "3) Install JetBrains Toolbox"
    echo "4) Install All IDEs"
    echo "5) Back"
    echo -n "Select option: "
    read -r i_choice
    case $i_choice in
        1) install_vscode ;;
        2) install_sublime ;;
        3) install_jetbrains_toolbox ;;
        4) install_ides ;;
        5) show_main_menu ;;
        *) log_message "WARN" "Invalid option"; show_ides_menu ;;
    esac
    show_main_menu
}

install_single_terminal() {
    local pkg="$1"
    if ! pkg_is_installed "$pkg" && ! command -v "$pkg" &> /dev/null; then
        confirm_install "$pkg" "$pkg" || return
        log_message "INFO" "Installing $pkg..."
        pkg_install_native "$pkg"
        log_message "SUCCESS" "$pkg installed."
        log_version "$pkg" "$pkg"
    else
        log_message "WARN" "$pkg is already installed."
    fi
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
        1) install_single_terminal kitty ;;
        2) install_single_terminal alacritty ;;
        3) install_single_terminal tilix ;;
        4) install_single_terminal gnome-terminal ;;
        5) install_terminals ;;
        6) show_main_menu ;;
        *) log_message "WARN" "Invalid option"; show_terminals_menu ;;
    esac
    show_main_menu
}

# --- Installation Modules (Expanded) ---

ensure_prerequisites() {
    pkg_ensure_prerequisites
}

update_system() {
    pkg_update_system
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
                log_message "INFO" "Installing Obsidian via apt..."
                apt install -y -V obsidian
                log_message "SUCCESS" "Obsidian installed via apt."
            elif command -v flatpak &> /dev/null; then
                log_message "INFO" "Installing Obsidian via Flatpak..."
                flatpak install -y flathub md.obsidian.Obsidian
                log_message "SUCCESS" "Obsidian installed via Flatpak."
            else
                log_message "INFO" "Flatpak not found. Downloading latest Obsidian .deb..."
                local deb_url=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
                    | jq -r '.assets[] | select(.name | endswith("_amd64.deb")) | .browser_download_url' \
                    | head -1)
                if [ -n "$deb_url" ] && [ "$deb_url" != "null" ]; then
                    if ! wget --progress=bar:force -O /tmp/obsidian.deb "$deb_url"; then
                        log_message "ERROR" "Failed to download Obsidian .deb"
                        rm -f /tmp/obsidian.deb
                        return
                    fi
                    dpkg -i /tmp/obsidian.deb || apt install -f -y
                    rm -f /tmp/obsidian.deb
                    log_message "SUCCESS" "Obsidian installed via .deb."
                else
                    log_message "ERROR" "Could not fetch Obsidian .deb URL."
                fi
            fi
            ;;
        arch)
            install_with_fallback "Obsidian" "obsidian" "obsidian" "md.obsidian.Obsidian" "obsidian"
            return $?
            ;;
    esac
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
                log_message "INFO" "Installing WPS Office via Flatpak..."
                flatpak install -y flathub com.wps.Office
            else
                log_message "INFO" "Installing Flatpak for WPS Office..."
                apt install -y -V flatpak
                flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                flatpak install -y flathub com.wps.Office
            fi
            ;;
        arch)
            install_with_fallback "WPS Office" "" "wps-office" "com.wps.Office" "wps"
            return $?
            ;;
    esac
    log_message "SUCCESS" "WPS Office installed via Flatpak."
}

install_obs_studio() {
    confirm_install "OBS Studio" "obs-studio" || return
    install_with_fallback "OBS Studio" "obs-studio" "obs-studio" "com.obsproject.Studio" "obs"
}

install_ffmpeg() {
    confirm_install "ffmpeg" "ffmpeg" || return
    install_with_fallback "ffmpeg" "ffmpeg" "ffmpeg" "org.ffmpeg.ffmpeg" "ffmpeg"
}

install_yt_dlp() {
    confirm_install "yt-dlp" "yt-dlp" || return
    install_with_fallback "yt-dlp" "yt-dlp" "yt-dlp" "" "yt-dlp"
}

install_utilities() {
    log_message "INFO" "--- Installing Utilities ---"
    for info in "${UTILITIES_LIST[@]}"; do
        local call="${info#*|}"
        call="${call%%|*}"
        $call
    done
}

install_vscode() {
    if command -v code &> /dev/null; then
        log_message "WARN" "VS Code is already installed."
        return
    fi

    confirm_install "VS Code" "code" || return

    case $DISTRO in
        debian)
            add_keyring "https://packages.microsoft.com/keys/microsoft.asc" \
                        "/usr/share/keyrings/packages.microsoft.gpg" \
                        "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
                        "vscode"
            apt update && apt install -y -V code
            ;;
        arch)
            install_with_fallback "VS Code" "code" "visual-studio-code-bin" "com.visualstudio.code" "code"
            return $?
            ;;
    esac
    log_message "SUCCESS" "VS Code installed."
    log_version "VS Code" code
}

install_sublime() {
    if command -v subl &> /dev/null; then
        log_message "WARN" "Sublime Text is already installed."
        return
    fi

    confirm_install "Sublime Text" "sublime-text" || return

    case $DISTRO in
        debian)
            add_keyring "https://download.sublimetext.com/sublimehq-pub.gpg" \
                        "/usr/share/keyrings/sublimehq-archive-keyring.gpg" \
                        "deb [signed-by=/usr/share/keyrings/sublimehq-archive-keyring.gpg] https://download.sublimetext.com/ apt/stable/" \
                        "sublime-text"
            apt update && apt install -y -V sublime-text
            ;;
        arch)
            install_with_fallback "Sublime Text" "" "sublime-text" "com.sublimetext.three" "subl"
            return $?
            ;;
    esac
    log_message "SUCCESS" "Sublime Text installed."
    log_version "Sublime Text" sublime-text
}

install_jetbrains_toolbox() {
    if [ -d "/opt/jetbrains-toolbox" ] || command -v jetbrains-toolbox &> /dev/null; then
        log_message "WARN" "JetBrains Toolbox is already installed."
        return
    fi

    confirm_install "JetBrains Toolbox" "" "Direct download from JetBrains" || return

    log_message "INFO" "Installing JetBrains Toolbox..."
    local toolbox_url=$(curl -s "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" \
        | jq -r '.TBA[0].downloads.linux.link')
    if [ -n "$toolbox_url" ] && [ "$toolbox_url" != "null" ]; then
        if ! wget --progress=bar:force -O /tmp/jetbrains-toolbox.tar.gz "$toolbox_url"; then
            log_message "ERROR" "Failed to download JetBrains Toolbox"
            rm -f /tmp/jetbrains-toolbox.tar.gz
            return
        fi
        mkdir -p /opt/jetbrains-toolbox
        tar xzf /tmp/jetbrains-toolbox.tar.gz -C /opt/jetbrains-toolbox --strip-components=1
        rm -f /tmp/jetbrains-toolbox.tar.gz
        ln -sf /opt/jetbrains-toolbox/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox
        log_message "SUCCESS" "JetBrains Toolbox installed."
        log_version "JetBrains Toolbox" "" jetbrains-toolbox
    else
        log_message "ERROR" "Could not fetch JetBrains Toolbox download URL."
    fi
}

install_ides() {
    log_message "INFO" "--- Installing All IDEs ---"
    for info in "${IDES_LIST[@]}"; do
        local call="${info#*|}"
        call="${call%%|*}"
        $call
    done
}

install_terminals() {
    log_message "INFO" "--- Installing All Terminals ---"
    for info in "${TERMINALS_LIST[@]}"; do
        local call="${info#*|}"
        call="${call%%|*}"
        $call
    done
}

# --- Execution Logic ---

run_installation() {
    log_message "INFO" "Starting installation..."

    if [ "$YES_MODE" = true ]; then
        ensure_prerequisites
        update_system

        if [ "$FULL_MODE" = true ] || [ "$MINIMAL_MODE" = true ]; then
            install_browsers
            install_terminals
        fi

        if [ "$FULL_MODE" = true ]; then
            install_utilities
            install_ides
            install_all_agentic_ides
        fi
    else
        case $FULL_MODE$MINIMAL_MODE in
            truefalse) show_selection_and_install "full" ;;
            falsetrue) show_selection_and_install "minimal" ;;
        esac
        return
    fi

    log_message "SUCCESS" "Installation tasks complete! Check $LOG_FILE for details."
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --minimal    Install only Browsers and Terminals"
    echo "  --full       Install everything (Browsers, Utilities, IDEs, Agentic IDEs, Terminals)"
    echo "  -y, --yes    Auto-confirm all installations (skip prompts)"
    echo "  --dry-run    Print what would be installed without actually installing"
    echo "  --help       Show this help message"
    echo ""
    echo "Run without options for interactive menu."
    exit 0
}

main() {
    check_sudo
    show_banner
    detect_distro

    # Check for flags
    if [[ $# -gt 0 ]]; then
        while [[ $# -gt 0 ]]; do
            case $1 in
            --minimal) MINIMAL_MODE=true; shift ;;
            --full)    FULL_MODE=true; shift ;;
            -y|--yes)  YES_MODE=true; shift ;;
            --dry-run) DRY_RUN=true; shift ;;
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
