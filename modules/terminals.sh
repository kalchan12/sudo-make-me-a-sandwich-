#!/bin/bash

TERMINALS_LIST=(
    "Kitty|install_kitty|kitty"
    "Alacritty|install_alacritty|alacritty"
    "Tilix|install_tilix|tilix"
    "GNOME Terminal|install_gnome_terminal|gnome-terminal"
    "Zellij|install_zellij|zellij"
    "tmux|install_tmux|tmux"
)

show_terminals_menu() {
    _render_menu TERMINALS_LIST "Terminals" \
        install_terminals check_terminals_installations show_main_menu
}

install_kitty() {
    if ! command -v kitty &> /dev/null; then
        confirm_install "Kitty" "kitty" || return
        install_with_fallback "Kitty" "kitty" "kitty" "org.xfce.kitty" "kitty"
        log_version "Kitty" kitty
    else
        log_message "INFO" "Kitty binary is already installed."
    fi

    local script_root
    script_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    if [ -f "$script_root/kitty-config/install.sh" ]; then
        bash "$script_root/kitty-config/install.sh"
    fi
}

install_alacritty() {
    if command -v alacritty &> /dev/null; then
        log_message "WARN" "Alacritty is already installed."
        return
    fi
    confirm_install "Alacritty" "alacritty" || return
    install_with_fallback "Alacritty" "alacritty" "alacritty" "org.alacritty.Alacritty" "alacritty"
    log_version "Alacritty" alacritty
}

install_tilix() {
    if command -v tilix &> /dev/null; then
        log_message "WARN" "Tilix is already installed."
        return
    fi
    confirm_install "Tilix" "tilix" || return
    install_with_fallback "Tilix" "tilix" "tilix" "com.gexperts.Tilix" "tilix"
    log_version "Tilix" tilix
}

install_gnome_terminal() {
    if command -v gnome-terminal &> /dev/null; then
        log_message "WARN" "GNOME Terminal is already installed."
        return
    fi
    confirm_install "GNOME Terminal" "gnome-terminal" || return
    install_with_fallback "GNOME Terminal" "gnome-terminal" "gnome-terminal" "" "gnome-terminal"
    log_version "GNOME Terminal" gnome-terminal
}

install_zellij() {
    if command -v zellij &> /dev/null; then
        log_message "WARN" "Zellij is already installed."
        return 0
    fi
    confirm_install "Zellij" "zellij" || return

    # 1. Native repository check (Arch, Fedora, etc.)
    if pkg_is_available "zellij"; then
        log_message "INFO" "Installing Zellij via $DISTRO package manager..."
        pkg_install_native "zellij"
        if command -v zellij &> /dev/null; then
            log_message "SUCCESS" "Zellij installed successfully."
            log_version "Zellij" zellij zellij
            return 0
        fi
    fi

    # 2. AUR on Arch Linux
    if [ "$DISTRO" = "arch" ]; then
        if command -v yay &> /dev/null; then
            yay -S --noconfirm zellij && return 0
        elif command -v paru &> /dev/null; then
            paru -S --noconfirm zellij && return 0
        fi
    fi

    # 3. Fast fallback: Official precompiled release binary from GitHub Releases
    log_message "INFO" "Zellij not found in distribution repos. Attempting prebuilt binary install..."
    local arch
    arch=$(uname -m)
    local zellij_tar=""
    case "$arch" in
        x86_64)  zellij_tar="zellij-x86_64-unknown-linux-musl.tar.gz" ;;
        aarch64) zellij_tar="zellij-aarch64-unknown-linux-musl.tar.gz" ;;
        armv7l)  zellij_tar="zellij-armv7-unknown-linux-musleabihf.tar.gz" ;;
    esac

    local prebuilt_ok=false
    if [ -n "$zellij_tar" ] && (command -v curl &>/dev/null || command -v wget &>/dev/null); then
        local dl_url="https://github.com/zellij-org/zellij/releases/latest/download/${zellij_tar}"
        local tmp_dir
        tmp_dir=$(mktemp -d /tmp/zellij-install.XXXXXX)
        log_message "INFO" "Downloading prebuilt release ($zellij_tar)..."
        local dl_success=false
        if command -v curl &>/dev/null; then
            curl -fsSL --connect-timeout 10 -m 60 -o "$tmp_dir/$zellij_tar" "$dl_url" && dl_success=true
        elif command -v wget &>/dev/null; then
            wget -q --timeout=10 --tries=2 -O "$tmp_dir/$zellij_tar" "$dl_url" && dl_success=true
        fi

        if [ "$dl_success" = true ] && [ -s "$tmp_dir/$zellij_tar" ]; then
            tar -xzf "$tmp_dir/$zellij_tar" -C "$tmp_dir" 2>/dev/null
            if [ -f "$tmp_dir/zellij" ]; then
                chmod +x "$tmp_dir/zellij"
                if [ -w "/usr/local/bin" ]; then
                    mv "$tmp_dir/zellij" /usr/local/bin/zellij
                    prebuilt_ok=true
                elif command -v sudo &>/dev/null; then
                    sudo mv "$tmp_dir/zellij" /usr/local/bin/zellij && prebuilt_ok=true
                elif [ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin"; then
                    mv "$tmp_dir/zellij" "$HOME/.local/bin/zellij"
                    prebuilt_ok=true
                fi
            fi
        fi
        rm -rf "$tmp_dir"
    fi

    if [ "$prebuilt_ok" = true ] && command -v zellij &> /dev/null; then
        log_message "SUCCESS" "Zellij installed successfully from release binary."
        log_version "Zellij" zellij zellij
        return 0
    fi

    # 4. Fallback: Build from source using cargo
    log_message "INFO" "Building Zellij from source (fallback)..."
    if ! command -v cargo &> /dev/null; then
        [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    fi

    if ! command -v cargo &> /dev/null; then
        log_message "INFO" "Rust/cargo not found. Installing build dependencies and Rust toolchain..."
        case $DISTRO in
            debian)
                pkg_install_native "build-essential" "pkg-config" "libssl-dev" "curl"
                ;;
            fedora)
                pkg_install_native "gcc" "gcc-c++" "pkgconfig" "openssl-devel" "curl"
                ;;
            arch)
                pkg_install_native "base-devel" "pkgconf" "openssl" "curl"
                ;;
        esac
        _verbose_cmd "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    fi

    if command -v cargo &> /dev/null; then
        log_message "INFO" "Compiling Zellij from source via cargo (this may take a few minutes)..."
        _verbose_cmd "cargo install --locked zellij"
        if cargo install --locked zellij; then
            if [ -f "$HOME/.cargo/bin/zellij" ]; then
                if [ -w "/usr/local/bin" ]; then
                    ln -sf "$HOME/.cargo/bin/zellij" /usr/local/bin/zellij 2>/dev/null || true
                elif command -v sudo &>/dev/null; then
                    sudo ln -sf "$HOME/.cargo/bin/zellij" /usr/local/bin/zellij 2>/dev/null || true
                fi
            fi
            log_message "SUCCESS" "Zellij built and installed from source successfully."
            log_version "Zellij" zellij zellij
            return 0
        else
            log_message "ERROR" "Failed to build Zellij from source."
            return 1
        fi
    else
        log_message "ERROR" "Cargo is unavailable. Could not build Zellij from source."
        return 1
    fi
}

install_terminals() { _install_list "Terminals" TERMINALS_LIST; }

check_terminals_installations() {
    _check_installations TERMINALS_LIST \
        "Kitty:kitty" "Alacritty:alacritty" "Tilix:tilix" "GNOME Terminal:gnome-terminal" \
        "Zellij:zellij" "tmux:tmux"
}
