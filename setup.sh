#!/bin/bash

# ==============================================================================
#  ███████╗██╗   ██╗██████╗  ██████╗  ██████╗     ███╗   ███╗ █████╗ ██╗  ██╗███████╗
#  ██╔════╝██║   ██║██╔══██╗██╔═══██╗██╔═══██╗    ████╗ ████║██╔══██╗██║ ██╔╝██╔════╝
#  ███████╗██║   ██║██████╔╝██║   ██║██║   ██║    ██╔████╔██║███████║█████╔╝ ███████╗
#  ╚════██║██║   ██║██╔══██╗██║   ██║██║   ██║    ██║╚██╔╝██║██╔══██║██╔═██╗ ╚════██║
#  ███████║╚██████╔╝██████╔╝╚██████╔╝╚██████╔╝    ██║ ╚═╝ ██║██║  ██║██║  ██╗███████║
#  ╚══════╝ ╚═════╝ ╚═════╝  ╚═════╝  ╚═════╝     ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
#
#  Modular Linux Bootstrapper (Debian/Arch/Fedora)
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

add_rpm_keyring() {
    local KEY_URL="$1"
    log_message "INFO" "Importing RPM GPG key..."
    if ! rpm --import "$KEY_URL"; then
        log_message "ERROR" "Failed to import RPM GPG key"
        return 1
    fi
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
    echo "5) Shells"
    echo "6) Agentic IDEs"
    echo "7) Dev Tools"
    echo "8) Programming Languages"
    echo "9) Full Installation (All Categories)"
    echo "10) Minimal Installation (Browsers + Terminals)"
    echo "11) Exit"
    echo -n "Select an option: "
    read -r choice
    case $choice in
        1) show_browsers_menu ;;
        2) show_utilities_menu ;;
        3) show_ides_menu ;;
        4) show_terminals_menu ;;
        5) show_shells_menu ;;
        6) show_agentic_ides_menu ;;
        7) show_dev_tools_menu ;;
        8) show_languages_menu ;;
        9) FULL_MODE=true; run_installation ;;
        10) MINIMAL_MODE=true; run_installation ;;
        11) log_message "INFO" "Exiting..."; exit 0 ;;
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
    echo -e "${CYAN}Enter a number to install, or e<N> for details (e.g., e1)${NC}"
    echo -n "Select option: "
    read -r u_choice
    if [[ "$u_choice" =~ ^e([0-9]+)$ ]]; then
        case "${BASH_REMATCH[1]}" in
            1) _explain_tool "Obsidian" ;;
            2) _explain_tool "WPS Office" ;;
            3) _explain_tool "OBS Studio" ;;
            4) _explain_tool "ffmpeg" ;;
            5) _explain_tool "yt-dlp" ;;
        esac
        show_utilities_menu; return
    fi
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
    echo -e "${CYAN}Enter a number to install, or e<N> for details (e.g., e1)${NC}"
    echo -n "Select option: "
    read -r i_choice
    if [[ "$i_choice" =~ ^e([0-9]+)$ ]]; then
        case "${BASH_REMATCH[1]}" in
            1) _explain_tool "VS Code" ;;
            2) _explain_tool "Sublime Text" ;;
            3) _explain_tool "JetBrains Toolbox" ;;
        esac
        show_ides_menu; return
    fi
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
    echo -e "${CYAN}Enter a number to install, or e<N> for details (e.g., e1)${NC}"
    echo -n "Select option: "
    read -r t_choice
    if [[ "$t_choice" =~ ^e([0-9]+)$ ]]; then
        case "${BASH_REMATCH[1]}" in
            1) _explain_tool "Kitty" ;;
            2) _explain_tool "Alacritty" ;;
            3) _explain_tool "Tilix" ;;
            4) _explain_tool "GNOME Terminal" ;;
        esac
        show_terminals_menu; return
    fi
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

_install_list() {
    local name="$1"
    local -n list="$2"
    log_message "INFO" "--- Installing All $name ---"
    for info in "${list[@]}"; do
        local call="${info#*|}"
        call="${call%%|*}"
        $call
    done
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
        fedora)
            install_with_fallback "Obsidian" "obsidian" "" "md.obsidian.Obsidian" "obsidian"
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
                pkg_install_native flatpak
                flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
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
    log_message "SUCCESS" "WPS Office installed via Flatpak."
}

install_obs_studio() {
    if command -v obs &> /dev/null; then
        log_message "WARN" "OBS Studio is already installed."
        return
    fi
    confirm_install "OBS Studio" "obs-studio" || return
    install_with_fallback "OBS Studio" "obs-studio" "obs-studio" "com.obsproject.Studio" "obs"
}

install_ffmpeg() {
    if command -v ffmpeg &> /dev/null; then
        log_message "WARN" "ffmpeg is already installed."
        return
    fi
    confirm_install "ffmpeg" "ffmpeg" || return
    install_with_fallback "ffmpeg" "ffmpeg" "ffmpeg" "org.ffmpeg.ffmpeg" "ffmpeg"
}

install_yt_dlp() {
    if command -v yt-dlp &> /dev/null; then
        log_message "WARN" "yt-dlp is already installed."
        return
    fi
    confirm_install "yt-dlp" "yt-dlp" || return
    install_with_fallback "yt-dlp" "yt-dlp" "yt-dlp" "" "yt-dlp"
}

install_utilities() { _install_list "Utilities" UTILITIES_LIST; }

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
        fedora)
            add_rpm_keyring "https://packages.microsoft.com/keys/microsoft.asc"
            cat > /etc/yum.repos.d/vscode.repo <<EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
            dnf install -y code
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
        fedora)
            add_rpm_keyring "https://download.sublimetext.com/sublimehq-rpm-pub.gpg"
            dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
            dnf install -y sublime-text
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

install_ides() { _install_list "IDEs" IDES_LIST; }

install_terminals() { _install_list "Terminals" TERMINALS_LIST; }

# --- Execution Logic ---

run_installation() {
    log_message "INFO" "Starting installation..."

    if [ "$YES_MODE" = true ]; then
        pkg_ensure_prerequisites
        pkg_update_system

        if [ "$FULL_MODE" = true ] || [ "$MINIMAL_MODE" = true ]; then
            install_browsers
            install_terminals
        fi

        if [ "$FULL_MODE" = true ]; then
            install_utilities
            install_ides
            install_shells
            install_all_agentic_ides
            install_dev_tools
            install_all_languages
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
    echo "  --full       Install everything (Browsers, Utilities, IDEs, Shells, Agentic IDEs, Dev Tools, Languages, Terminals)"
    echo "  -y, --yes    Auto-confirm all installations (skip prompts)"
    echo "  --dry-run    Print what would be installed without actually installing"
    echo "  --explain    Show info about a tool (e.g., --explain tmux)"
    echo "  --help       Show this help message"
    echo ""
    echo "Run without options for interactive menu."
    echo "Inside menus, enter a number to install, or e<N> for details (e.g., e1)."
    exit 0
}

main() {
    # Handle non-sudo flags early
    if [[ $# -gt 0 ]]; then
        case $1 in
            --help)
                usage
                ;;
            --explain)
                if [ -n "$2" ]; then
                    _explain_tool "$2"
                    exit 0
                else
                    log_message "ERROR" "--explain requires a tool name"
                    usage
                fi
                ;;
        esac
    fi

    check_sudo
    show_banner
    detect_distro
    show_persona

    # Check for install flags
    if [[ $# -gt 0 ]]; then
        while [[ $# -gt 0 ]]; do
            case $1 in
            --minimal) MINIMAL_MODE=true; shift ;;
            --full)    FULL_MODE=true; shift ;;
            -y|--yes)  YES_MODE=true; shift ;;
            --dry-run) DRY_RUN=true; shift ;;
            --help|--explain) shift ;;
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
