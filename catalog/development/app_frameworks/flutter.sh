# id: flutter
# name: Flutter
# desc: Flutter SDK.
# method: snap
# pkg: flutter
# tags: dev,framework

install_flutter() {
    if command -v flutter &> /dev/null; then
        log_message "WARN" "Flutter is already installed."
        return
    fi

    confirm_install "Flutter" "flutter" || return

    case $DISTRO in
        debian)
            _check_deps "Flutter" curl git unzip xz-utils zip libglu1-mesa || return
            if ! command -v snap &> /dev/null; then
                log_message "INFO" "Installing snapd for Flutter..."
                _verbose_cmd "apt update && apt install -y snapd"
                apt update && apt install -y snapd
            fi
            _verbose_cmd "snap install flutter --classic"
            snap install flutter --classic
            ;;
        arch)
            if command -v yay &> /dev/null; then
                _verbose_cmd "yay -S --noconfirm flutter"
                yay -S --noconfirm flutter
            elif command -v paru &> /dev/null; then
                _verbose_cmd "paru -S --noconfirm flutter"
                paru -S --noconfirm flutter
            else
                log_message "ERROR" "No AUR helper found. Install yay or paru first."
                return 1
            fi
            ;;
        fedora)
            _check_deps "Flutter" curl git unzip xz zip mesa-libGLU || return
            if ! command -v snap &> /dev/null; then
                log_message "INFO" "Installing snapd for Flutter..."
                _verbose_cmd "dnf install -y snapd"
                dnf install -y snapd
                systemctl enable --now snapd.socket
                ln -sf /var/lib/snapd/snap /snap
            fi
            _verbose_cmd "snap install flutter --classic"
            snap install flutter --classic
            ;;
    esac

    if command -v flutter &> /dev/null; then
        log_message "SUCCESS" "Flutter installed."
        log_version "Flutter" flutter flutter
    else
        log_message "ERROR" "Flutter installation failed."
    fi
}
