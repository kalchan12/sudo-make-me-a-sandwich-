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
exec 3>>"$LOG_FILE"

MINIMAL_MODE=false
FULL_MODE=false
DRY_RUN="${DRY_RUN:-false}"
YES_MODE=false
UNINSTALL_MODE=false
VERBOSE_MODE=false
START_TIME=0
INSTALL_LIST=""

RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

gecho() { echo -e "${GREEN}$*${NC}"; }

# --- Helper Functions ---

show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "███████╗██╗   ██╗██████╗  ██████╗ "
    echo "██╔════╝██║   ██║██╔══██╗██╔═══██╗"
    echo "███████╗██║   ██║██║  ██║██║   ██║"
    echo "╚════██║██║   ██║██║  ██║██║   ██║"
    echo "███████║╚██████╔╝██████╔╝╚██████╔╝"
    echo "╚══════╝ ╚═════╝ ╚═════╝  ╚═════╝ "
    echo -e "${NC}"
    echo -e "${PURPLE}  ⚡ MAKE ME A SANDWICH ⚡  |  author: psycho${NC}"
    gecho "  ─────────────────────────────────────────────────────────────────────────────"
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
    
    echo "[$TIMESTAMP] [$TYPE] $MSG" >&3
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
        gecho "  └─ $display:  $version"
        log_message "INFO" "$display version: $version"
    fi
}

_dry_run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} $*"
        return 0
    fi
    "$@"
}

_print_summary() {
    local elapsed=$(($(date +%s) - START_TIME))
    local mins=$((elapsed / 60))
    local secs=$((elapsed % 60))

    echo ""
    echo -e "${PURPLE}═══════════════════════════════════════${NC}"
    echo -e "${PURPLE}      Installation Complete${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════${NC}"
    gecho "  Elapsed time: ${mins}m ${secs}s"
    gecho "  Log file: ${LOG_FILE}"
    echo ""
}

list_tools() {
    echo -e "${PURPLE}Available Tools by Category${NC}"
    echo ""

    _print_category "Browsers" BROWSERS_LIST
    _print_category "Productivity" PRODUCTIVITY_LIST
    _print_category "IDEs & Editors" IDES_LIST
    _print_category "Terminals" TERMINALS_LIST
    _print_category "Shells" SHELLS_LIST
    _print_category "Dev Tools" DEV_TOOLS_LIST
    _print_category "Languages" LANGUAGES_LIST
    _print_category "Pentesting Tools" PENTEST_LIST

    exit 0
}

_print_category() {
    local title="$1"
    local -n list="$2"
    echo -e "${PURPLE}── $title ──${NC}"
    for info in "${list[@]}"; do
        local name="${info%%|*}"
        gecho "  • $name"
    done
    echo ""
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
    [ -f "$c" ] || continue
    case "$(basename "$c")" in
        python_*.sh) continue ;;  # Python API — sourced only by subprocess
    esac
    source "$c"
done

# --- Python Bridge (if available) ---
if command -v python3 &> /dev/null && python3 -c "import rich" 2>/dev/null; then
    source "$CORE_DIR/python_bridge.sh"
fi

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

PRODUCTIVITY_LIST=(
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
    "OpenCode|install_opencode|"
    "ZCode|install_zcode|"
    "Antigravity|install_antigravity|"
    "Kiro|install_kiro|"
)

# --- Interactive Menu Functions ---

show_main_menu() {
    echo -e "${PURPLE}═══════════════════════════════════════${NC}"
    echo -e "${PURPLE}           Main Menu${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════${NC}"
    echo -e " ${YELLOW}1)${GREEN} Browsers${NC}${NC}"
    echo -e " ${YELLOW}2)${GREEN} Productivity${NC}${NC}"
    echo -e " ${YELLOW}3)${GREEN} IDEs & Editors${NC}${NC}"
    echo -e " ${YELLOW}4)${GREEN} Terminals${NC}${NC}"
    echo -e " ${YELLOW}5)${GREEN} Shells${NC}${NC}"
    echo -e " ${YELLOW}6)${GREEN} Dev Tools${NC}${NC}"
    echo -e " ${YELLOW}7)${GREEN} Programming Languages${NC}${NC}"
    echo -e " ${YELLOW}8)${GREEN} Pentesting Tools${NC}${NC}"
    echo -e " ${YELLOW}9)${GREEN} Frameworks${NC}${NC}"
    echo -e " ${YELLOW}10)${GREEN} Full Installation${NC}${NC}"
    echo -e " ${YELLOW}11)${GREEN} Minimal Installation${NC}${NC}"
    echo -e " ${YELLOW}12)${GREEN} Exit${NC}${NC}"
    echo -n -e "${PURPLE}Select an option: ${NC}${YELLOW}"
    read -r choice
    echo -e -n "${NC}"
    case $choice in
        1) show_browsers_menu ;;
        2) show_productivity_menu ;;
        3) show_ides_menu ;;
        4) show_terminals_menu ;;
        5) show_shells_menu ;;
        6) show_dev_tools_menu ;;
        7) show_languages_menu ;;
        8) show_pentest_menu ;;
        9) show_frameworks_menu ;;
        10) FULL_MODE=true; run_installation ;;
        11) MINIMAL_MODE=true; run_installation ;;
        12) log_message "INFO" "Exiting..."; exit 0 ;;
        *) log_message "WARN" "Invalid option: $choice"; show_main_menu ;;
    esac
}

show_productivity_menu() {
    _render_menu PRODUCTIVITY_LIST "Productivity" \
        install_productivity check_productivity_installations show_main_menu
}

show_ides_menu() {
    _render_menu IDES_LIST "IDEs & Editors" \
        install_ides check_ides_installations show_main_menu
}

install_single_terminal() {
    local pkg="$1"
    if [ "$UNINSTALL_MODE" = true ]; then
        if command -v "$pkg" &> /dev/null; then
            log_message "INFO" "Removing $pkg..."
            pkg_remove "$pkg"
        else
            log_message "WARN" "$pkg is not installed."
        fi
        return
    fi
    if ! pkg_is_installed "$pkg" && ! command -v "$pkg" &> /dev/null; then
        confirm_install "$pkg" "$pkg" || return
        log_message "INFO" "Installing $pkg..."
        pkg_install_native "$pkg"
        local ec=$?
        if [ "$ec" -eq 0 ]; then
            log_message "SUCCESS" "$pkg installed."
            log_version "$pkg" "$pkg"
        fi
        return "$ec"
    else
        log_message "WARN" "$pkg is already installed."
    fi
}

show_terminals_menu() {
    while true; do
        echo -e "\n${PURPLE}── Terminals ──${NC}"
        echo -e "${YELLOW}1)${GREEN} Install Kitty${NC}${NC}"
        echo -e "${YELLOW}2)${GREEN} Install Alacritty${NC}${NC}"
        echo -e "${YELLOW}3)${GREEN} Install Tilix${NC}${NC}"
        echo -e "${YELLOW}4)${GREEN} Install GNOME Terminal${NC}${NC}"
        echo -e "${YELLOW}5)${GREEN} Install All Terminals${NC}${NC}"
        echo -e "${YELLOW}6)${GREEN} Check Installations${NC}${NC}"
        echo -e "${YELLOW}7)${GREEN} Back${NC}${NC}"
        echo -e "${PURPLE}Enter a number to install, or e<N> for details (e.g., e1)${NC}"
        echo -n -e "${PURPLE}Select option: ${NC}${YELLOW}"
        read -r t_choice
        echo -e -n "${NC}"
        if [[ "$t_choice" =~ ^e([0-9]+)$ ]]; then
            case "${BASH_REMATCH[1]}" in
                1) _explain_tool "Kitty" ;;
                2) _explain_tool "Alacritty" ;;
                3) _explain_tool "Tilix" ;;
                4) _explain_tool "GNOME Terminal" ;;
            esac
            continue
        fi
        case $t_choice in
            1) install_single_terminal kitty ;;
            2) install_single_terminal alacritty ;;
            3) install_single_terminal tilix ;;
            4) install_single_terminal gnome-terminal ;;
            5) install_terminals ;;
            6) check_terminals_installations ;;
            7) show_main_menu; return ;;
            *) log_message "WARN" "Invalid option"; continue ;;
        esac
    done
}

# --- Generic Menu & Check Helpers ---

# Generic menu renderer
# Usage: _render_menu LIST_VAR "Title" on_all_callback on_check_callback on_back_callback
_render_menu() {
    local -n _list="$1"
    local _title="$2"
    local _on_all="$3"
    local _on_check="$4"
    local _on_back="$5"

    while true; do
        echo -e "\n${PURPLE}── ${_title} ──${NC}"
        local i=1
        for _info in "${_list[@]}"; do
            local _name="${_info%%|*}"
            echo -e "${YELLOW}${i})${GREEN} Install ${_name}${NC}"
            ((i++))
        done
        local _all_idx=$i
        echo -e "${YELLOW}${_all_idx})${GREEN} Install All${NC}"
        local _check_idx=$((_all_idx + 1))
        echo -e "${YELLOW}${_check_idx})${GREEN} Check Installations${NC}"
        local _back_idx=$((_all_idx + 2))
        echo -e "${YELLOW}${_back_idx})${GREEN} Back${NC}"
        echo -e "${PURPLE}Enter a number to install, or e<N> for details (e.g., e1)${NC}"
        echo -n -e "${PURPLE}Select option: ${NC}${YELLOW}"
        read -r _choice
        echo -e -n "${NC}"

        if [[ "$_choice" =~ ^e([0-9]+)$ ]]; then
            _explain_by_index "$1" "${BASH_REMATCH[1]}"
            continue
        elif [[ "$_choice" = "all" ]] || [[ "$_choice" = "$_all_idx" ]]; then
            "$_on_all"
        elif [[ "$_choice" = "$_check_idx" ]]; then
            "$_on_check"
        elif [[ "$_choice" = "$_back_idx" ]]; then
            $_on_back; return
        elif [[ "$_choice" =~ ^[0-9]+$ ]] && [ "$_choice" -ge 1 ] && [ "$_choice" -lt "$_all_idx" ]; then
            local _idx=0
            for _info in "${_list[@]}"; do
                if [ "$_idx" -eq $((_choice - 1)) ]; then
                    local _call="${_info#*|}"
                    _call="${_call%%|*}"
                    $_call
                    break
                fi
                ((_idx++))
            done
        else
            log_message "WARN" "Invalid option"
        fi
    done
}

# Generic installation checker
# Usage: _check_installations LIST_VAR "Name1:bin1" "Name2:bin2" ...
_check_installations() {
    local -n _list="$1"
    shift
    declare -A _bin_map
    for _pair in "$@"; do
        _bin_map["${_pair%%:*}"]="${_pair#*:}"
    done

    log_message "INFO" "--- Checking $(echo "$1" | sed 's/_LIST$//') Installations ---"
    for _info in "${_list[@]}"; do
        local _name="${_info%%|*}"
        local _installed=false
        if [[ -n "${_bin_map[_name]}" ]]; then
            bin_check "${_bin_map[_name]}" && _installed=true
        else
            # fallback: try lowercase name
            bin_check "$(echo "$_name" | tr '[:upper:]' '[:lower:]')" && _installed=true
        fi
        if [ "$_installed" = true ]; then
            echo -e "${GREEN}[✔] ${_name} is installed.${NC}"
        else
            echo -e "${RED}[✘] ${_name} is NOT installed.${NC}"
        fi
    done
}

# --- Installation Modules (Expanded) ---

_install_list() {
    local name="$1"
    local -n list="$2"
    local prefix="Installing"
    [ "$UNINSTALL_MODE" = true ] && prefix="Removing"
    log_message "INFO" "--- $prefix All $name ---"
    local overall_ec=0
    for info in "${list[@]}"; do
        local item_name="${info%%|*}"
        local call="${info#*|}"
        call="${call%%|*}"
        $call
        local ec=$?
        if [ "$ec" -ne 0 ]; then
            log_message "ERROR" "$call failed for $item_name (exit code $ec)."
            overall_ec=$ec
        fi
    done
    return "$overall_ec"
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
    if [ "$DISTRO" = "debian" ]; then
        _check_deps "OBS Studio (recommended)" libavcodec-extra
    fi
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

install_productivity() { _install_list "Productivity" PRODUCTIVITY_LIST; }

check_productivity_installations() {
    _check_installations PRODUCTIVITY_LIST \
        "Obsidian:obsidian" "WPS Office:wps" "OBS Studio:obs" \
        "ffmpeg:ffmpeg" "yt-dlp:yt-dlp"
}

check_ides_installations() {
    _check_installations IDES_LIST \
        "VS Code:code" "Sublime Text:subl" "JetBrains Toolbox:jetbrains-toolbox" \
        "OpenCode:opencode" "ZCode:zcode" "Antigravity:antigravity" "Kiro:kiro"
}

check_terminals_installations() {
    _check_installations TERMINALS_LIST \
        "Kitty:kitty" "Alacritty:alacritty" "Tilix:tilix" "GNOME Terminal:gnome-terminal"
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
    _check_deps "JetBrains Toolbox" curl jq wget || return

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

install_ides() { _install_list "IDEs & Editors" IDES_LIST; }

check_ides_installations() {
    log_message "INFO" "--- Checking IDE Installations ---"
    for info in "${IDES_LIST[@]}"; do
        local name="${info%%|*}"
        local installed=false
        case $name in
            "VS Code") bin_check code && installed=true ;;
            "Sublime Text") bin_check subl && installed=true ;;
            "JetBrains Toolbox") bin_check jetbrains-toolbox && installed=true ;;
            OpenCode) bin_check opencode && installed=true ;;
            ZCode) bin_check zcode && installed=true ;;
            Antigravity) bin_check antigravity && installed=true ;;
            Kiro) bin_check kiro && installed=true ;;
        esac
        if [ "$installed" = true ]; then
            echo -e "${GREEN}[✔] $name is installed.${NC}"
        else
            echo -e "${RED}[✘] $name is NOT installed.${NC}"
        fi
    done
}

install_terminals() { _install_list "Terminals" TERMINALS_LIST; }

check_terminals_installations() {
    log_message "INFO" "--- Checking Terminal Installations ---"
    for info in "${TERMINALS_LIST[@]}"; do
        local name="${info%%|*}"
        local installed=false
        case $name in
            Kitty) bin_check kitty && installed=true ;;
            Alacritty) bin_check alacritty && installed=true ;;
            Tilix) bin_check tilix && installed=true ;;
            "GNOME Terminal") bin_check gnome-terminal && installed=true ;;
        esac
        if [ "$installed" = true ]; then
            echo -e "${GREEN}[✔] $name is installed.${NC}"
        else
            echo -e "${RED}[✘] $name is NOT installed.${NC}"
        fi
    done
}

# --- Execution Logic ---

run_installation() {
    START_TIME=$(date +%s)
    log_message "INFO" "Starting installation..."

    if [ "$YES_MODE" = true ]; then
        pkg_ensure_prerequisites
        pkg_update_system

        if [ "$FULL_MODE" = true ] || [ "$MINIMAL_MODE" = true ]; then
            install_browsers
            install_terminals
        fi

        if [ "$FULL_MODE" = true ]; then
            install_productivity
            install_ides
            install_shells
            install_dev_tools
            install_all_languages
            install_pentest
        fi
    else
        case $FULL_MODE$MINIMAL_MODE in
            truefalse) show_selection_and_install "full" ;;
            falsetrue) show_selection_and_install "minimal" ;;
        esac
        _print_summary
        return
    fi

    log_message "SUCCESS" "Installation tasks complete! Check $LOG_FILE for details."
    _print_summary
}

install_by_name() {
    local target="$1"
    local target_lower
    target_lower=$(echo "$target" | tr '[:upper:]' '[:lower:]')

    local all_lists=(
        "BROWSERS_LIST" "TERMINALS_LIST" "PRODUCTIVITY_LIST" "IDES_LIST"
        "SHELLS_LIST" "DEV_TOOLS_LIST" "LANGUAGES_LIST"
        "PENTEST_LIST"
    )

    local list_name
    for list_name in "${all_lists[@]}"; do
        local -n list="$list_name"
        for info in "${list[@]}"; do
            local name="${info%%|*}"
            local name_lower
            name_lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')
            if [ "$name_lower" = "$target_lower" ]; then
                local rest="${info#*|}"
                local call="${rest%%|*}"
                log_message "INFO" "Installing $name..."
                $call
                return $?
            fi
        done
    done

    log_message "ERROR" "Unknown tool: '$target'. Use --list to see all available tools."
    return 1
}

install_multiple() {
    local IFS=','
    for tool in $1; do
        tool=$(echo "$tool" | xargs)
        install_by_name "$tool" || true
    done
}

usage() {
    gecho "Usage: $0 [OPTIONS]"
    gecho "Options:"
    gecho "  --minimal    Install only Browsers and Terminals"
    gecho "  --full       Install everything (Browsers, Productivity, IDEs, Shells, Dev Tools, Languages, Terminals, Pentesting)"
    gecho "  -y, --yes    Auto-confirm all installations (skip prompts)"
    gecho "  --dry-run    Print what would be installed without actually installing"
    gecho "  --explain    Show info about a tool (e.g., --explain tmux)"
    gecho "  --install    Install specific tools by name (comma-separated, e.g. --install nmap,burpsuite)"
    gecho "  --list       List all available tools by category and exit"
    gecho "  --uninstall  Uninstall selected tools instead of installing"
    gecho "  -v, --verbose  Show actual commands being executed"
    gecho "  --help       Show this help message"
    gecho ""
    gecho "Run without options for interactive menu."
    gecho "Inside menus, enter a number to install, or e<N> for details (e.g., e1)."
    exit 0
}

main() {
    # Handle non-sudo flags early (process all args)
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-python)
                shift
                ;;
            --banner-only)
                show_banner
                exit 0
                ;;
            --help)
                usage
                ;;
            --list)
                if command -v python3 &> /dev/null && python3 -c "import rich" 2>/dev/null; then
                    python3 "$(dirname "$0")/src/main.py" list
                else
                    list_tools
                fi
                exit 0
                ;;
            --explain)
                if [ -n "$2" ]; then
                    if command -v python3 &> /dev/null && python3 -c "import rich" 2>/dev/null; then
                        python3 "$(dirname "$0")/src/main.py" explain "$2"
                    else
                        _explain_tool "$2"
                    fi
                    exit 0
                else
                    log_message "ERROR" "--explain requires a tool name"
                    usage
                fi
                ;;
            *)
                break
                ;;
        esac
    done

    # Parse --dry-run and --verbose early so check_sudo can see them
    for arg in "$@"; do
        if [ "$arg" = "--dry-run" ]; then
            DRY_RUN=true
        elif [ "$arg" = "--verbose" ] || [ "$arg" = "-v" ]; then
            VERBOSE_MODE=true
        fi
    done
    # Also check env vars (for DRY_RUN=true source setup.sh)
    [ "${DRY_RUN:-}" = "true" ] && DRY_RUN=true
    [ "${VERBOSE_MODE:-}" = "true" ] && VERBOSE_MODE=true

    check_sudo
    show_banner
    detect_distro
    show_persona
    if [ "$UNINSTALL_MODE" = true ]; then
        echo -e "${YELLOW} ⚠ UNINSTALL MODE — tools will be REMOVED, not installed.${NC}"
        echo ""
    fi

    # Check for install flags
    if [[ $# -gt 0 ]]; then
        while [[ $# -gt 0 ]]; do
            case $1 in
            --minimal) MINIMAL_MODE=true; shift ;;
            --full)    FULL_MODE=true; shift ;;
            -y|--yes)  YES_MODE=true; shift ;;
            -v|--verbose) VERBOSE_MODE=true; shift ;;
            --dry-run) DRY_RUN=true; shift ;;
            --uninstall) UNINSTALL_MODE=true; shift ;;
            --install) INSTALL_LIST="$2"; shift 2 ;;
            --help|--explain|--list) shift ;;
                *)         log_message "ERROR" "Unknown option: $1"; usage ;;
            esac
        done
        if [ -n "$INSTALL_LIST" ]; then
            install_multiple "$INSTALL_LIST"
        else
            run_installation
        fi
    else
        # No flags, enter interactive mode
        show_main_menu
    fi
}

main "$@"
