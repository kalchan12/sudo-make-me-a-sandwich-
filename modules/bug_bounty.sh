#!/bin/bash

# ==============================================================================
# Bug Bounty Tools Module
# ==============================================================================

BUG_BOUNTY_LIST=(
    "subfinder|install_subfinder|subfinder"
    "httpx|install_httpx|httpx-toolkit"
    "nuclei|install_nuclei|nuclei"
    "katana|install_katana|katana"
    "ghidra|install_ghidra|ghidra"
    "caido|install_caido|caido"
)

_verify_install() {
    local name="$1"
    local binary="$2"
    if command -v "$binary" &> /dev/null; then
        return 0
    fi
    log_message "WARN" "$name was installed but '$binary' was not found in PATH."
    log_message "WARN" "Try running: hash -r  (or restart your shell) and check again."
    return 1
}

show_bug_bounty_menu() {
    _render_menu BUG_BOUNTY_LIST "Bug Bounty Tools" \
        install_bug_bounty check_bug_bounty_installations show_main_menu
}

# --- Subdomain & Asset Discovery ---

install_subfinder() {
    if [ "$UNINSTALL_MODE" = true ]; then
        if command -v subfinder &> /dev/null; then
            log_message "INFO" "Removing subfinder..."
            pkg_remove subfinder
            rm -f /usr/local/bin/subfinder
            return 0
        else
            log_message "WARN" "subfinder is not installed."
            return 0
        fi
    fi

    if command -v subfinder &> /dev/null; then
        log_message "WARN" "subfinder is already installed."
        return 0
    fi
    confirm_install "subfinder" "subfinder" || return

    if pkg_is_available "subfinder"; then
        log_message "INFO" "Installing subfinder via package manager..."
        pkg_install_native subfinder
    elif [ "$DISTRO" = "arch" ] && aur_install "subfinder-bin"; then
        :
    elif command -v go &> /dev/null; then
        log_message "INFO" "Installing subfinder via Go..."
        _check_deps "subfinder" git || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
            return 0
        fi
        _verbose_cmd "go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
        go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
        if [ -f "$HOME/go/bin/subfinder" ]; then
            ln -sf "$HOME/go/bin/subfinder" /usr/local/bin/subfinder
        fi
    else
        log_message "INFO" "Downloading pre-compiled subfinder release from GitHub..."
        _check_deps "subfinder" curl unzip || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Download and install subfinder from GitHub releases to /usr/local/bin/subfinder"
            return 0
        fi
        local tag
        tag=$(curl -sI https://github.com/projectdiscovery/subfinder/releases/latest | grep -i "^location:" | sed -E 's/.*tag\/v?([0-9.]+).*/\1/' | tr -d '\r\n')
        tag="${tag:-2.6.8}"
        local zip_url="https://github.com/projectdiscovery/subfinder/releases/download/v${tag}/subfinder_${tag}_linux_amd64.zip"
        if curl -fsSL "$zip_url" -o /tmp/subfinder.zip; then
            unzip -qo /tmp/subfinder.zip subfinder -d /usr/local/bin/
            chmod +x /usr/local/bin/subfinder
            rm -f /tmp/subfinder.zip
        else
            log_message "ERROR" "Failed to download subfinder release from GitHub."
            rm -f /tmp/subfinder.zip
            return 1
        fi
    fi

    _verify_install "subfinder" subfinder
    log_version "subfinder" "subfinder" subfinder
}

# --- HTTP Probing & Analysis ---

install_httpx() {
    if [ "$UNINSTALL_MODE" = true ]; then
        if command -v httpx &> /dev/null || command -v httpx-toolkit &> /dev/null; then
            log_message "INFO" "Removing httpx..."
            pkg_remove httpx-toolkit httpx
            rm -f /usr/local/bin/httpx
            return 0
        else
            log_message "WARN" "httpx is not installed."
            return 0
        fi
    fi

    if command -v httpx &> /dev/null || command -v httpx-toolkit &> /dev/null; then
        log_message "WARN" "httpx is already installed."
        return 0
    fi
    confirm_install "httpx" "httpx-toolkit" || return

    if pkg_is_available "httpx-toolkit"; then
        log_message "INFO" "Installing httpx-toolkit via package manager..."
        pkg_install_native httpx-toolkit
        if [ -f /usr/bin/httpx-toolkit ] && [ ! -e /usr/local/bin/httpx ]; then
            ln -sf /usr/bin/httpx-toolkit /usr/local/bin/httpx
        fi
    elif pkg_is_available "httpx"; then
        log_message "INFO" "Installing httpx via package manager..."
        pkg_install_native httpx
    elif [ "$DISTRO" = "arch" ] && aur_install "httpx-bin"; then
        :
    elif command -v go &> /dev/null; then
        log_message "INFO" "Installing httpx via Go..."
        _check_deps "httpx" git || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
            return 0
        fi
        _verbose_cmd "go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
        go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
        if [ -f "$HOME/go/bin/httpx" ]; then
            ln -sf "$HOME/go/bin/httpx" /usr/local/bin/httpx
        fi
    else
        log_message "INFO" "Downloading pre-compiled httpx release from GitHub..."
        _check_deps "httpx" curl unzip || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Download and install httpx from GitHub releases to /usr/local/bin/httpx"
            return 0
        fi
        local tag
        tag=$(curl -sI https://github.com/projectdiscovery/httpx/releases/latest | grep -i "^location:" | sed -E 's/.*tag\/v?([0-9.]+).*/\1/' | tr -d '\r\n')
        tag="${tag:-1.6.9}"
        local zip_url="https://github.com/projectdiscovery/httpx/releases/download/v${tag}/httpx_${tag}_linux_amd64.zip"
        if curl -fsSL "$zip_url" -o /tmp/httpx.zip; then
            unzip -qo /tmp/httpx.zip httpx -d /usr/local/bin/
            chmod +x /usr/local/bin/httpx
            rm -f /tmp/httpx.zip
        else
            log_message "ERROR" "Failed to download httpx release from GitHub."
            rm -f /tmp/httpx.zip
            return 1
        fi
    fi

    if command -v httpx &> /dev/null; then
        _verify_install "httpx" httpx
        log_version "httpx" "" httpx
    elif command -v httpx-toolkit &> /dev/null; then
        _verify_install "httpx" httpx-toolkit
        log_version "httpx" "httpx-toolkit" httpx-toolkit
    fi
}

# --- Vulnerability Scanning ---

install_nuclei() {
    if [ "$UNINSTALL_MODE" = true ]; then
        if command -v nuclei &> /dev/null; then
            log_message "INFO" "Removing nuclei..."
            pkg_remove nuclei
            rm -f /usr/local/bin/nuclei
            return 0
        else
            log_message "WARN" "nuclei is not installed."
            return 0
        fi
    fi

    if command -v nuclei &> /dev/null; then
        log_message "WARN" "nuclei is already installed."
        return 0
    fi
    confirm_install "nuclei" "nuclei" || return

    if pkg_is_available "nuclei"; then
        log_message "INFO" "Installing nuclei via package manager..."
        pkg_install_native nuclei
    elif [ "$DISTRO" = "arch" ] && aur_install "nuclei-bin"; then
        :
    elif command -v go &> /dev/null; then
        log_message "INFO" "Installing nuclei via Go..."
        _check_deps "nuclei" git || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
            return 0
        fi
        _verbose_cmd "go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
        go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
        if [ -f "$HOME/go/bin/nuclei" ]; then
            ln -sf "$HOME/go/bin/nuclei" /usr/local/bin/nuclei
        fi
    else
        log_message "INFO" "Downloading pre-compiled nuclei release from GitHub..."
        _check_deps "nuclei" curl unzip || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Download and install nuclei from GitHub releases to /usr/local/bin/nuclei"
            return 0
        fi
        local tag
        tag=$(curl -sI https://github.com/projectdiscovery/nuclei/releases/latest | grep -i "^location:" | sed -E 's/.*tag\/v?([0-9.]+).*/\1/' | tr -d '\r\n')
        tag="${tag:-3.3.6}"
        local zip_url="https://github.com/projectdiscovery/nuclei/releases/download/v${tag}/nuclei_${tag}_linux_amd64.zip"
        if curl -fsSL "$zip_url" -o /tmp/nuclei.zip; then
            unzip -qo /tmp/nuclei.zip nuclei -d /usr/local/bin/
            chmod +x /usr/local/bin/nuclei
            rm -f /tmp/nuclei.zip
        else
            log_message "ERROR" "Failed to download nuclei release from GitHub."
            rm -f /tmp/nuclei.zip
            return 1
        fi
    fi

    _verify_install "nuclei" nuclei
    log_version "nuclei" "nuclei" nuclei
}

# --- Web Crawling & Spidering ---

install_katana() {
    if [ "$UNINSTALL_MODE" = true ]; then
        if command -v katana &> /dev/null; then
            log_message "INFO" "Removing katana..."
            pkg_remove katana
            rm -f /usr/local/bin/katana
            return 0
        else
            log_message "WARN" "katana is not installed."
            return 0
        fi
    fi

    if command -v katana &> /dev/null; then
        log_message "WARN" "katana is already installed."
        return 0
    fi
    confirm_install "katana" "katana" || return

    if pkg_is_available "katana"; then
        log_message "INFO" "Installing katana via package manager..."
        pkg_install_native katana
    elif [ "$DISTRO" = "arch" ] && aur_install "katana-bin"; then
        :
    elif command -v go &> /dev/null; then
        log_message "INFO" "Installing katana via Go..."
        _check_deps "katana" git || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} go install -v github.com/projectdiscovery/katana/cmd/katana@latest"
            return 0
        fi
        _verbose_cmd "go install -v github.com/projectdiscovery/katana/cmd/katana@latest"
        go install -v github.com/projectdiscovery/katana/cmd/katana@latest
        if [ -f "$HOME/go/bin/katana" ]; then
            ln -sf "$HOME/go/bin/katana" /usr/local/bin/katana
        fi
    else
        log_message "INFO" "Downloading pre-compiled katana release from GitHub..."
        _check_deps "katana" curl unzip || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Download and install katana from GitHub releases to /usr/local/bin/katana"
            return 0
        fi
        local tag
        tag=$(curl -sI https://github.com/projectdiscovery/katana/releases/latest | grep -i "^location:" | sed -E 's/.*tag\/v?([0-9.]+).*/\1/' | tr -d '\r\n')
        tag="${tag:-1.1.0}"
        local zip_url="https://github.com/projectdiscovery/katana/releases/download/v${tag}/katana_${tag}_linux_amd64.zip"
        if curl -fsSL "$zip_url" -o /tmp/katana.zip; then
            unzip -qo /tmp/katana.zip katana -d /usr/local/bin/
            chmod +x /usr/local/bin/katana
            rm -f /tmp/katana.zip
        else
            log_message "ERROR" "Failed to download katana release from GitHub."
            rm -f /tmp/katana.zip
            return 1
        fi
    fi

    _verify_install "katana" katana
    log_version "katana" "katana" katana
}

# --- Reverse Engineering & Decompilation ---

install_ghidra() {
    if [ "$UNINSTALL_MODE" = true ]; then
        if command -v ghidra &> /dev/null || [ -d "/opt/ghidra" ]; then
            log_message "INFO" "Removing Ghidra..."
            pkg_remove ghidra
            rm -rf /opt/ghidra /usr/local/bin/ghidra /usr/share/applications/ghidra.desktop
            return 0
        else
            log_message "WARN" "Ghidra is not installed."
            return 0
        fi
    fi

    if command -v ghidra &> /dev/null || [ -d "/opt/ghidra" ]; then
        log_message "WARN" "Ghidra is already installed."
        return 0
    fi
    confirm_install "ghidra" "ghidra" || return

    if pkg_is_available "ghidra"; then
        log_message "INFO" "Installing Ghidra via package manager..."
        pkg_install_native ghidra
    elif [ "$DISTRO" = "arch" ] && aur_install "ghidra-bin"; then
        :
    else
        log_message "INFO" "Ghidra package not found in repos. Installing Java JDK dependencies..."
        case $DISTRO in
            debian) pkg_install_native default-jdk wget unzip ;;
            arch)   pkg_install_native jdk-openjdk wget unzip ;;
            fedora) pkg_install_native java-latest-openjdk wget unzip ;;
        esac

        log_message "INFO" "Downloading official Ghidra release from GitHub..."
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Download Ghidra release, extract to /opt/ghidra, and link /usr/local/bin/ghidra"
            return 0
        fi

        local release_url
        release_url=$(curl -sL https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest 2>/dev/null | grep "browser_download_url.*PUBLIC.*\.zip" | head -1 | cut -d '"' -f 4)
        if [ -z "$release_url" ]; then
            release_url="https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.2.1_build/ghidra_11.2.1_PUBLIC_20241105.zip"
        fi

        mkdir -p /opt/ghidra /tmp/ghidra_download
        if wget --progress=bar:force -O /tmp/ghidra.zip "$release_url"; then
            unzip -qo /tmp/ghidra.zip -d /tmp/ghidra_download/
            local ghidra_dir
            ghidra_dir=$(find /tmp/ghidra_download -mindepth 1 -maxdepth 1 -type d | head -1)
            if [ -n "$ghidra_dir" ]; then
                cp -r "$ghidra_dir"/* /opt/ghidra/
                ln -sf /opt/ghidra/ghidraRun /usr/local/bin/ghidra
                chmod +x /opt/ghidra/ghidraRun /usr/local/bin/ghidra

                cat > /usr/share/applications/ghidra.desktop << 'DESKTOP'
[Desktop Entry]
Name=Ghidra
Comment=Software Reverse Engineering Framework
Exec=/usr/local/bin/ghidra
Icon=/opt/ghidra/docs/images/GHIDRA_1.png
Terminal=false
Type=Application
Categories=Development;Security;
DESKTOP
            fi
            rm -rf /tmp/ghidra.zip /tmp/ghidra_download
        else
            log_message "ERROR" "Failed to download Ghidra release."
            rm -rf /tmp/ghidra.zip /tmp/ghidra_download
            return 1
        fi
    fi

    _verify_install "ghidra" ghidra
    log_version "ghidra" "ghidra" ghidra
}

# --- Web Proxy & Auditing ---

install_caido() {
    if [ "$UNINSTALL_MODE" = true ]; then
        if command -v caido &> /dev/null || [ -d "/opt/caido" ]; then
            log_message "INFO" "Removing Caido..."
            pkg_remove caido
            rm -rf /opt/caido /usr/local/bin/caido /usr/share/applications/caido.desktop
            return 0
        else
            log_message "WARN" "Caido is not installed."
            return 0
        fi
    fi

    if command -v caido &> /dev/null || [ -f "/opt/caido/caido" ]; then
        log_message "WARN" "Caido is already installed."
        return 0
    fi
    confirm_install "caido" "caido" || return

    if pkg_is_available "caido"; then
        log_message "INFO" "Installing Caido via package manager..."
        pkg_install_native caido
    elif [ "$DISTRO" = "arch" ] && aur_install "caido-desktop"; then
        :
    else
        log_message "INFO" "Downloading Caido CLI package..."
        _check_deps "caido" curl tar || return 1
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Download Caido CLI and install to /usr/local/bin/caido"
            return 0
        fi

        local tag
        tag=$(curl -sI https://github.com/caido/caido/releases/latest | grep -i "^location:" | sed -E 's/.*tag\/v?([0-9.]+).*/\1/' | tr -d '\r\n')
        tag="${tag:-0.45.0}"
        local tar_url="https://github.com/caido/caido/releases/download/v${tag}/caido-cli-v${tag}-linux-x86_64.tar.gz"

        mkdir -p /opt/caido
        if curl -fsSL "$tar_url" -o /tmp/caido.tar.gz; then
            tar -xzf /tmp/caido.tar.gz -C /opt/caido
            ln -sf /opt/caido/caido /usr/local/bin/caido
            chmod +x /opt/caido/caido
            rm -f /tmp/caido.tar.gz
        else
            log_message "ERROR" "Failed to download Caido release."
            rm -f /tmp/caido.tar.gz
            return 1
        fi
    fi

    _verify_install "caido" caido
    log_version "caido" "caido" caido
}

# --- Module Checks & Batch Operations ---

check_bug_bounty_installations() {
    log_message "INFO" "--- Checking Bug Bounty Installations ---"
    for info in "${BUG_BOUNTY_LIST[@]}"; do
        local name="${info%%|*}"
        local installed=false
        case $name in
            subfinder) bin_check subfinder && installed=true ;;
            httpx) (bin_check httpx || bin_check httpx-toolkit) && installed=true ;;
            nuclei) bin_check nuclei && installed=true ;;
            katana) bin_check katana && installed=true ;;
            ghidra) (bin_check ghidra || bin_check ghidraRun || [ -d /opt/ghidra ]) && installed=true ;;
            caido) (bin_check caido || bin_check caido-cli || [ -f /opt/caido/caido ]) && installed=true ;;
        esac
        if [ "$installed" = true ]; then
            echo -e "${GREEN}[✔] $name is installed.${NC}"
        else
            echo -e "${RED}[✘] $name is NOT installed.${NC}"
        fi
    done
}

install_bug_bounty() { _install_list "Bug Bounty Tools" BUG_BOUNTY_LIST; }
install_all_bug_bounty() { _install_list "Bug Bounty Tools" BUG_BOUNTY_LIST; }
