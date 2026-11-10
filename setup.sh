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
PRESETS_DIR="$(cd "$(dirname "$0")" && pwd)/presets"
if ! exec 3>>"$LOG_FILE" 2>/dev/null; then
    LOG_FILE="/tmp/sandwich-install.log"
    exec 3>>"$LOG_FILE" 2>/dev/null || exec 3>/dev/null
fi

MINIMAL_MODE=false
FULL_MODE=false
UPDATE_MODE=false
PROFILE_NAME=""
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
    local TIMESTAMP
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    
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
        echo -e "${YELLOW}⚡ Please re-run this script with sudo:${NC}"
        echo -e "   ${GREEN}sudo ./setup.sh${NC}"
        echo ""
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

    catalog_init
    local g
    for g in "${CATALOG_GROUPS[@]}"; do
        local gp
        gp="$(catalog_group_path "$g")"
        catalog_categories "$gp"
        local c
        for c in "${CATALOG_CAT_LIST[@]}"; do
            echo -e "${PURPLE}── $(catalog_title "$c") ──${NC}"
            catalog_tools "$c"
            local t
            for t in "${CATALOG_TOOLS[@]}"; do
                local name="${t%%|*}"
                gecho "  • $name"
            done
            echo ""
        done
    done
    exit 0
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


# --- Interactive Menu Functions ---

show_group_menu() {
    local gp="$1"
    local back_cb="$2"
    local title
    title="$(catalog_title "$gp")"
    echo ""
    echo -e "${PURPLE}── $title ──${NC}"
    catalog_categories "$gp"
    local i=1
    local c
    for c in "${CATALOG_CAT_LIST[@]}"; do
        local cnt
        cnt="$(catalog_tool_count_for "$c")"
        echo -e "${YELLOW}${i})${GREEN} $(catalog_title "$c") (${cnt})${NC}"
        i=$((i+1))
    done
    echo -e "${YELLOW}${i})${GREEN} Back${NC}"
    echo -n -e "${PURPLE}Select option: ${NC}${YELLOW}"
    local g_choice
    read -r g_choice
    echo -e -n "${NC}"
    if [[ "$g_choice" =~ ^[0-9]+$ ]] && [ "$g_choice" -ge 1 ] && [ "$g_choice" -lt "$i" ]; then
        local sel="$((g_choice - 1))"
        show_catalog_menu "${CATALOG_CAT_LIST[$sel]}" "$back_cb"
        return 0
    fi
    eval "$back_cb"
    return 0
}

show_main_menu() {
    echo -e "${PURPLE}═══════════════════════════════════════${NC}"
    echo -e "${PURPLE}           Main Menu${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════${NC}"
    echo -e " ${YELLOW}0)${GREEN} General${NC}"
    echo -e " ${YELLOW}1)${GREEN} Development${NC}"
    echo -e " ${YELLOW}2)${GREEN} Security${NC}"
    echo -e " ${YELLOW}3)${GREEN} Full Installation${NC}"
    echo -e " ${YELLOW}4)${GREEN} Minimal Installation${NC}"
    echo -e " ${YELLOW}g)${CYAN} Launch Desktop GUI${NC}"
    echo -e " ${YELLOW}5)${GREEN} Exit${NC}"
    echo -n -e "${PURPLE}Select an option: ${NC}${YELLOW}"
    read -r choice
    echo -e -n "${NC}"
    case $choice in
        0) show_group_menu "general" show_main_menu ;;
        1) show_group_menu "development" show_main_menu ;;
        2) show_group_menu "security" show_main_menu ;;
        3) FULL_MODE=true; run_installation ;;
        4) MINIMAL_MODE=true; run_installation ;;
        g|G|[gG][uU][iI])
            if _can_launch_gui; then
                _exec_gui
            else
                log_message "WARN" "GUI is not available (no display detected)."
                show_main_menu
            fi
            ;;
        5) log_message "INFO" "Exiting..."; exit 0 ;;
        *) log_message "WARN" "Invalid option: $choice"; show_main_menu ;;
    esac
}





# --- Installation Helpers (Expanded) ---


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
                local deb_url
                deb_url=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
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

install_productivity() { catalog_install_path "general/apps"; catalog_install_path "general/privacy/passwords"; catalog_install_path "general/privacy/network"; }

check_productivity_installations() {
    catalog_check_path "general/apps"
    catalog_check_path "general/privacy/passwords"
    catalog_check_path "general/privacy/network"
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
    local toolbox_url
    toolbox_url=$(curl -s "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" \
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

install_ides() { catalog_install_path "development/editors_ides"; }

check_ides_installations() {
    catalog_check_path "development/editors_ides"
}

install_terminals() { catalog_install_path "general/terminal_shells/terminals"; }

check_terminals_installations() {
    catalog_check_path "general/terminal_shells/terminals"
}

# --- Execution Logic ---

install_profile() {
    local name="$1"
    local file="${PRESETS_DIR}/${name}.list"
    if [ ! -f "$file" ]; then
        local available
        available=$(for f in "${PRESETS_DIR}"/*.list; do [ -f "$f" ] && basename "$f"; done | tr '\n' ' ')
        log_message "ERROR" "Unknown profile: '$name'. Available: $available"
        return 1
    fi
    local tool
    while IFS= read -r tool; do
        tool="$(echo "$tool" | xargs)"
        case "$tool" in
            ""|\#*) continue ;;
        esac
        if [ "$tool" = "ALL" ]; then
            catalog_install_all
        else
            catalog_install_one "$tool"
        fi
    done < "$file"
    return 0
}

run_installation() {
    START_TIME=$(date +%s)
    log_message "INFO" "Starting installation..."

    if [ -n "$PROFILE_NAME" ]; then
        install_profile "$PROFILE_NAME"
        return $?
    fi

    if [ "$YES_MODE" = true ]; then
        pkg_ensure_prerequisites
        if [ "$UPDATE_MODE" = true ]; then
            pkg_update_system
        fi

        if [ "$FULL_MODE" = true ] || [ "$MINIMAL_MODE" = true ]; then
            if [ "$MINIMAL_MODE" = true ]; then
                catalog_install_path "general/browsers"
                catalog_install_path "general/terminal_shells/terminals"
            fi

            if [ "$FULL_MODE" = true ]; then
                catalog_install_all
            fi
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

    local entry
    for entry in "${CATALOG_ORDERED[@]}"; do
        # shellcheck disable=SC2034  # only a subset of catalog fields is used here
        IFS='|' read -r e_path e_id e_name e_desc e_method e_tags e_fn e_pkg <<< "$entry"
        if [ "$e_id" = "$target_lower" ]; then
            eval "$e_fn"
            return $?
        fi
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
    gecho "  --gui        Launch Graphical User Interface (GUI)"
    gecho "  --cli, --tui Force terminal interactive mode (skip GUI auto-detection)"
    gecho "  --minimal    Install only Browsers and Terminals"
    gecho "  --full       Install everything (Browsers, Productivity, IDEs, Shells, Dev Tools, Languages, Terminals, Pentesting)"
    gecho "  -y, --yes    Auto-confirm all installations (skip prompts)"
    gecho "  --dry-run    Print what would be installed without actually installing"
    gecho "  -u, --update Update system packages first (opt-in; not done by default)"
    gecho "  --explain    Show info about a tool (e.g., --explain tmux)"
    gecho "  --install    Install specific tools by name (comma-separated, e.g. --install nmap,burpsuite)"
    gecho "  --list       List all available tools by category and exit"
    gecho "  --profile <name>  Install tools from presets/<name>.list (e.g. --profile psycho)"
    gecho "  --uninstall  Uninstall selected tools instead of installing"
    gecho "  -v, --verbose  Show actual commands being executed"
    gecho "  --help       Show this help message"
    gecho ""
    gecho "Run without options for interactive mode (choose Terminal or GUI)."
    gecho "Inside menus, enter a number to install, or e<N> for details (e.g., e1)."
    exit 0
}

main() {
    local GUI_REQUESTED=false
    local CLI_REQUESTED=false
    local ACTION_SPECIFIED=false

    # Scan arguments early
    for arg in "$@"; do
        case "$arg" in
            --gui)
                GUI_REQUESTED=true
                ;;
            --cli|--tui)
                CLI_REQUESTED=true
                ;;
            --dry-run)
                DRY_RUN=true
                ;;
            -v|--verbose)
                VERBOSE_MODE=true
                ;;
            --minimal|--full|-u|--update|--install|--uninstall|--help|--list|--explain|--banner-only)
                ACTION_SPECIFIED=true
                ;;
            --profile)
                ;;
        esac
    done
    [ "${DRY_RUN:-}" = "true" ] && DRY_RUN=true
    [ "${VERBOSE_MODE:-}" = "true" ] && VERBOSE_MODE=true

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # If running under sudo and DISPLAY is not set, preserve desktop user's X environment
    if [ -n "$SUDO_USER" ]; then
        export DISPLAY="${DISPLAY:-:0}"
        if [ -z "$XAUTHORITY" ] && [ -f "/home/$SUDO_USER/.Xauthority" ]; then
            export XAUTHORITY="/home/$SUDO_USER/.Xauthority"
        fi
        sudo -u "$SUDO_USER" xhost +si:localuser:root 2>/dev/null || true
    fi

    # Helper function: test if graphical environment is available
    _can_launch_gui() {
        [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && return 1
        command -v python3 &>/dev/null || return 1
        PYTHONPATH="$script_dir" python3 -c "from src.gui.launcher import is_gui_available; import sys; sys.exit(0 if is_gui_available() else 1)" 2>/dev/null
    }

    _exec_gui() {
        if [ -n "$SUDO_USER" ] && [ "$EUID" -eq 0 ]; then
            exec sudo -u "$SUDO_USER" env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" PYTHONPATH="$script_dir" python3 "$script_dir/src/main.py" gui "$@"
        else
            PYTHONPATH="$script_dir" exec python3 "$script_dir/src/main.py" gui "$@"
        fi
    }

    # Decide whether to launch GUI or Terminal:
    if [ "$GUI_REQUESTED" = true ]; then
        _exec_gui "$@"
    elif [ "$CLI_REQUESTED" = true ] || [ "$ACTION_SPECIFIED" = true ]; then
        : # Proceed directly to terminal flow
    elif [ ! -t 0 ]; then
        # Launched non-interactively without terminal stdin (e.g. from desktop launcher)
        if _can_launch_gui; then
            _exec_gui "$@"
        fi
    else
        # Running interactively inside a terminal with no explicit flags:
        # Give the user a clear choice between Terminal Installer (default) and Desktop GUI
        if _can_launch_gui; then
            echo ""
            echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════╗${NC}"
            echo -e "${PURPLE}║               ⚡ MAKE ME A SANDWICH ⚡                    ║${NC}"
            echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════╝${NC}"
            echo -e "  Select interface mode:"
            echo -e "    ${YELLOW}1)${GREEN} Terminal Interactive Menu (CLI / TUI)  ${CYAN}[Default]${NC}"
            echo -e "    ${YELLOW}2)${GREEN} Graphical User Interface (Desktop GUI)${NC}"
            echo ""
            local mode_choice=""
            read -t 10 -r -p "  Enter choice [1/2] (auto-selects 1 in 10s): " mode_choice || true
            echo ""
            case "$mode_choice" in
                2|[gG]|[gG][uU][iI])
                    _exec_gui "$@"
                    ;;
                *)
                    # Default: continue to terminal flow
                    ;;
            esac
        fi
    fi

    # --- Terminal Execution Flow ---

    # Handle quick terminal flags
    local pass_args=()
    while [[ $# -gt 0 ]]; do
        case $1 in
            --gui|--cli|--tui)
                shift
                ;;
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
                pass_args+=("$1")
                shift
                ;;
        esac
    done

    # Restore remaining args for standard installer parsing
    set -- "${pass_args[@]}"

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
            -u|--update) UPDATE_MODE=true; shift ;;
            -y|--yes)  YES_MODE=true; shift ;;
            -v|--verbose) VERBOSE_MODE=true; shift ;;
            --dry-run) DRY_RUN=true; shift ;;
            --uninstall) UNINSTALL_MODE=true; shift ;;
            --install) INSTALL_LIST="$2"; shift 2 ;;
            --profile) PROFILE_NAME="$2"; shift 2 ;;
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
        # Terminal interactive mode: prefer Rich TUI if available, otherwise bash menu
        if command -v python3 &> /dev/null && python3 -c "import rich" 2>/dev/null; then
            exec python3 "$(dirname "$0")/src/main.py" interactive
        else
            show_main_menu
        fi
    fi
}

main "$@"
