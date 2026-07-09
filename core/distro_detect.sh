# Distro detection
detect_distro() {
    local pretty_name=""
    local distro_id=""
    local distro_like=""
    if [ -f /etc/os-release ]; then
        pretty_name=$(grep -oP '(?<=^PRETTY_NAME=")[^"]*' /etc/os-release)
        distro_id=$(grep -oP '(?<=^ID=)[a-z]+' /etc/os-release)
        distro_like=$(grep -oP '(?<=^ID_LIKE=")[^"]*' /etc/os-release)
    fi
    local kernel_version
    kernel_version=$(uname -r)

    if [ -f /etc/debian_version ]; then
        DISTRO="debian"
        gecho "Detected distro: Debian-based ($pretty_name, kernel $kernel_version)"
        echo "[$(date "+%Y-%m-%d %H:%M:%S")] [INFO] Detected distro: Debian-based ($pretty_name, kernel $kernel_version)" >> "$LOG_FILE"
    elif [ -f /etc/arch-release ]; then
        DISTRO="arch"
        if [ "$distro_id" = "arch" ]; then
            gecho "Detected distro: Arch Linux ($pretty_name, kernel $kernel_version)"
            echo "[$(date "+%Y-%m-%d %H:%M:%S")] [INFO] Detected distro: Arch Linux ($pretty_name, kernel $kernel_version)" >> "$LOG_FILE"
        else
            gecho "Detected distro: Arch-based ($pretty_name, kernel $kernel_version)"
            echo "[$(date "+%Y-%m-%d %H:%M:%S")] [INFO] Detected distro: Arch-based ($pretty_name, kernel $kernel_version)" >> "$LOG_FILE"
        fi
    elif [ "$distro_id" = "fedora" ] || echo "$distro_like" | grep -qi "fedora"; then
        DISTRO="fedora"
        gecho "Detected distro: Fedora-based ($pretty_name, kernel $kernel_version)"
        echo "[$(date "+%Y-%m-%d %H:%M:%S")] [INFO] Detected distro: Fedora-based ($pretty_name, kernel $kernel_version)" >> "$LOG_FILE"
    elif [ -f /etc/fedora-release ]; then
        DISTRO="fedora"
        gecho "Detected distro: Fedora-based ($pretty_name, kernel $kernel_version)"
        echo "[$(date "+%Y-%m-%d %H:%M:%S")] [INFO] Detected distro: Fedora-based ($pretty_name, kernel $kernel_version)" >> "$LOG_FILE"
    else
        log_message "ERROR" "Unsupported distro (only Debian-based, Arch and Fedora-based are supported)"
        exit 1
    fi
}

pkg_is_installed() {
    case $DISTRO in
        debian) dpkg -s "$1" &> /dev/null ;;
        arch) pacman -Q "$1" &> /dev/null 2>&1 ;;
        fedora) rpm -q "$1" &> /dev/null ;;
        *) return 1 ;;
    esac
}

pkg_install_native() {
    if [ "$DRY_RUN" = true ]; then
        case $DISTRO in
            debian) echo -e "${YELLOW}[DRY-RUN]${NC} apt install -y -V $*" ;;
            arch)   echo -e "${YELLOW}[DRY-RUN]${NC} pacman -S --noconfirm $*" ;;
            fedora) echo -e "${YELLOW}[DRY-RUN]${NC} dnf install -y $*" ;;
        esac
        return
    fi
    case $DISTRO in
        debian) apt install -y -V "$@" ;;
        arch) pacman -S --noconfirm "$@" ;;
        fedora) dnf install -y "$@" ;;
    esac
}

pkg_is_available() {
    case $DISTRO in
        debian) apt-cache show "$1" &> /dev/null ;;
        arch) pacman -Si "$1" &> /dev/null 2>&1 ;;
        fedora) dnf info "$1" &> /dev/null ;;
        *) return 1 ;;
    esac
}

aur_install() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} AUR install: $1 (via yay/paru)"
        return 0
    fi
    if command -v yay &> /dev/null; then
        yay -S --noconfirm "$1"
    elif command -v paru &> /dev/null; then
        paru -S --noconfirm "$1"
    else
        return 1
    fi
}

_flatpak_install() {
    local display_name="$1"
    local flatpak_id="$2"
    local bin_check="$3"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} flatpak install -y flathub $flatpak_id"
        return 0
    fi
    flatpak install -y flathub "$flatpak_id"
    log_message "SUCCESS" "$display_name installed via Flatpak."
    log_version "$display_name" "" "$bin_check"
}

install_with_fallback() {
    local display_name="$1"
    local pkg_native="$2"
    local pkg_aur="${3:-$pkg_native}"
    local flatpak_id="$4"
    local bin_check="${5:-$pkg_native}"

    if command -v "$bin_check" &> /dev/null; then
        log_message "WARN" "$display_name is already installed."
        return 0
    fi

    if pkg_is_available "$pkg_native"; then
        log_message "INFO" "Installing $display_name via $DISTRO package manager..."
        pkg_install_native "$pkg_native"
        log_message "SUCCESS" "$display_name installed."
        log_version "$display_name" "$pkg_native" "$bin_check"
        return 0
    fi

    if [ "$DISTRO" = "arch" ] && aur_install "$pkg_aur"; then
        log_message "SUCCESS" "$display_name installed via AUR."
        log_version "$display_name" "" "$bin_check"
        return 0
    fi

    if [ -n "$flatpak_id" ] && command -v flatpak &> /dev/null; then
        log_message "INFO" "Installing $display_name via Flatpak..."
        _flatpak_install "$display_name" "$flatpak_id" "$bin_check"
        return 0
    fi

    if [ -n "$flatpak_id" ]; then
        log_message "INFO" "Installing Flatpak for $display_name..."
        pkg_install_native flatpak
        if [ "$DRY_RUN" = false ]; then
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        fi
        _flatpak_install "$display_name" "$flatpak_id" "$bin_check"
        return 0
    fi

    log_message "ERROR" "$display_name not available."
    return 1
}

pkg_update_system() {
    if [ "$DRY_RUN" = true ]; then
        case $DISTRO in
            debian) echo -e "${YELLOW}[DRY-RUN]${NC} apt update && apt upgrade -y -V" ;;
            arch)   echo -e "${YELLOW}[DRY-RUN]${NC} pacman -Syu --noconfirm" ;;
            fedora) echo -e "${YELLOW}[DRY-RUN]${NC} dnf upgrade -y" ;;
        esac
        return
    fi
    log_message "INFO" "Updating package lists and upgrading system..."
    case $DISTRO in
        debian) apt update && apt upgrade -y -V ;;
        arch) pacman -Syu --noconfirm ;;
        fedora) dnf upgrade -y ;;
    esac
    log_message "SUCCESS" "System is up to date."
}

pkg_ensure_prerequisites() {
    local -A pkg_map
    pkg_map[curl]=curl
    pkg_map[wget]=wget
    pkg_map[gpg]=gnupg
    pkg_map[lsb_release]=lsb-release
    pkg_map[jq]=jq
    pkg_map[flatpak]=flatpak

    local missing_pkgs=()
    for cmd in "${!pkg_map[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            local pkg="${pkg_map[$cmd]}"
            if [ "$DISTRO" = "fedora" ] && [ "$cmd" = "lsb_release" ]; then
                pkg="redhat-lsb-core"
            fi
            missing_pkgs+=("$pkg")
        fi
    done

    if [ "$DISTRO" = "fedora" ] && ! dnf config-manager --help &>/dev/null 2>&1; then
        missing_pkgs+=("dnf-utils")
    fi

    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        log_message "INFO" "Installing missing prerequisites: ${missing_pkgs[*]}"
        pkg_install_native "${missing_pkgs[@]}"
    fi
}

_check_deps() {
    local tool="$1"
    shift
    local missing=()
    for dep in "$@"; do
        if ! command -v "$dep" &> /dev/null && ! pkg_is_installed "$dep" &> /dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Would install dependencies: ${missing[*]}"
            return 0
        fi
        log_message "INFO" "$tool requires: ${missing[*]}"
        confirm_install "dependencies (${missing[*]})" "" || return 1
        pkg_install_native "${missing[@]}"
    fi
}
