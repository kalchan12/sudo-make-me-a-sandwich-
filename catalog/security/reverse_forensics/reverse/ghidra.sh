#!/usr/bin/env bash
# id: ghidra
# name: Reverse engineering
# desc: Reverse engineering toolkit.
# method: jdk
# pkg: ghidra
# tags: security,re

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
