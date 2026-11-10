# id: librewolf
# name: LibreWolf
# desc: Community Firefox fork with privacy hardening.
# method: apt
# pkg: librewolf
# tags: browser,privacy

install_librewolf() {
    if command -v librewolf &> /dev/null; then
        log_message "WARN" "LibreWolf is already installed."
        return
    fi

    confirm_install "LibreWolf" "librewolf" || return

    case $DISTRO in
        debian)
            log_message "INFO" "Installing LibreWolf..."
            pkg_ensure_prerequisites
            local keyring_url="https://deb.librewolf.net/keyring.gpg"
            local keyring_path="/usr/share/keyrings/librewolf.gpg"
            curl -fsSL "$keyring_url" | gpg --dearmor -o "$keyring_path"
            echo "deb [arch=amd64 signed-by=$keyring_path] https://deb.librewolf.net $(lsb_release -sc) main" > /etc/apt/sources.list.d/librewolf.list
            _verbose_cmd "apt update && apt install -y -V librewolf"
            apt update && apt install -y -V librewolf
            ;;
        arch)
            install_with_fallback "LibreWolf" "librewolf" "librewolf-bin" "io.gitlab.librewolf-community" "librewolf"
            return $?
            ;;
        fedora)
            dnf copr enable -y kunzusan/librewolf
            _verbose_cmd "dnf install -y librewolf"
            dnf install -y librewolf
            ;;
    esac
    log_message "SUCCESS" "LibreWolf installed."
    log_version "LibreWolf" librewolf
}
