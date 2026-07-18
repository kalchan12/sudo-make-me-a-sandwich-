#!/bin/bash
# Python API — thin bridge for Python to call bash install functions
# Usage: bash core/python_api.sh <function_name> [args...]

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Source core modules
source "$SCRIPT_DIR/core/distro_detect.sh"
source "$SCRIPT_DIR/core/confirm.sh"

# Source config from setup.sh
LOG_FILE="$SCRIPT_DIR/install.log"
exec 3>>"$LOG_FILE"

# Minimal gecho/log_message for the API
GREEN='\033[1;32m'
NC='\033[0m'
log_message() {
    local TYPE=$1 MSG=$2
    local TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] [$TYPE] $MSG" >&3
}

# Run detect_distro at least once to set DISTRO, PKG_MANAGER, etc.
detect_distro > /dev/null 2>&1

# --- API Functions ---

# Show package info without prompting (for Python confirm_install)
show_package_info() {
    local pkg="$1"
    case $DISTRO in
        debian) apt-cache show "$pkg" 2>/dev/null | grep -E "^(Package|Version|Description-en|Description|Size|Installed-Size)\b" | head -10 ;;
        arch)   pacman -Si "$pkg" 2>/dev/null | grep -E "^(Name|Version|Description|Download Size|Installed Size)" | head -10 ;;
        fedora) dnf info "$pkg" 2>/dev/null | grep -E "^(Name|Version|Summary|Download size|Installed size)" | head -10 ;;
    esac
}

# Call the requested function
"$@"
exit $?
