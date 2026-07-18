#!/bin/bash

# ==============================================================================
# Frameworks Module — Mobile, Web, Backend frameworks
# ==============================================================================

# Format: "Display Name|function_call|pkg_name_for_size"
FRAMEWORKS_LIST=(
    "Flutter|install_flutter|flutter"
    "React Native|install_react_native|"
    "Next.js|install_nextjs|"
    "Node.js (Latest)|install_nodejs_latest|"
    "Electron|install_electron|"
    "Tauri|install_tauri|"
    "Deno|install_deno|deno"
    "Bun|install_bun|bun"
)

show_frameworks_menu() {
    _render_menu FRAMEWORKS_LIST "Frameworks" \
        install_frameworks check_frameworks_installations show_main_menu
}

# --- Flutter ---
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

# --- React Native ---
install_react_native() {
    if command -v npx &> /dev/null && npx react-native --version &> /dev/null; then
        log_message "WARN" "React Native CLI is already available."
        return
    fi

    confirm_install "React Native" "" "Requires Node.js and npm" || return

    if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
        log_message "ERROR" "Node.js and npm are required. Install Node.js first."
        return 1
    fi

    log_message "INFO" "Installing React Native CLI globally..."
    _verbose_cmd "npm install -g @react-native-community/cli"
    if npm install -g @react-native-community/cli; then
        log_message "SUCCESS" "React Native CLI installed."
        log_version "React Native" "" "react-native"
    else
        log_message "ERROR" "Failed to install React Native CLI."
        return 1
    fi
}

# --- Next.js ---
install_nextjs() {
    if command -v npx &> /dev/null && npx create-next-app --version &> /dev/null; then
        log_message "WARN" "Next.js is already available via npx."
        return
    fi

    confirm_install "Next.js" "" "Requires Node.js and npm" || return

    if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
        log_message "ERROR" "Node.js and npm are required. Install Node.js first."
        return 1
    fi

    log_message "INFO" "Next.js is available via npx. No global install needed."
    log_message "INFO" "Run 'npx create-next-app@latest my-app' to create a new project."
    log_message "SUCCESS" "Next.js ready to use via npx."
}

# --- Node.js Latest ---
install_nodejs_latest() {
    if command -v node &> /dev/null; then
        local current_version
        current_version=$(node --version)
        log_message "INFO" "Node.js is already installed ($current_version)."
        log_message "INFO" "This will install the latest LTS version via NodeSource."
    fi

    confirm_install "Node.js (Latest LTS)" "nodejs" || return

    case $DISTRO in
        debian)
            _verbose_cmd "curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -"
            curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
            _verbose_cmd "apt install -y -V nodejs"
            apt install -y -V nodejs
            ;;
        arch)
            pkg_install_native nodejs npm
            ;;
        fedora)
            _verbose_cmd "curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash -"
            curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash -
            _verbose_cmd "dnf install -y nodejs"
            dnf install -y nodejs
            ;;
    esac

    log_message "SUCCESS" "Node.js LTS installed."
    log_version "Node.js" nodejs node
}

# --- Electron ---
install_electron() {
    if command -v electron &> /dev/null; then
        log_message "WARN" "Electron is already installed."
        return
    fi

    confirm_install "Electron" "" "Requires Node.js and npm" || return

    if ! command -v npm &> /dev/null; then
        log_message "ERROR" "npm is required. Install Node.js first."
        return 1
    fi

    log_message "INFO" "Installing Electron globally..."
    _verbose_cmd "npm install -g electron"
    if npm install -g electron; then
        log_message "SUCCESS" "Electron installed."
        log_version "Electron" "" electron
    else
        log_message "ERROR" "Failed to install Electron."
        return 1
    fi
}

# --- Tauri ---
install_tauri() {
    if command -v cargo &> /dev/null && cargo install --list | grep -q tauri-cli; then
        log_message "WARN" "Tauri CLI is already installed."
        return
    fi

    confirm_install "Tauri" "" "Requires Rust (cargo)" || return

    if ! command -v cargo &> /dev/null; then
        log_message "ERROR" "Rust/cargo is required. Install Rust first."
        return 1
    fi

    log_message "INFO" "Installing Tauri CLI..."
    _verbose_cmd "cargo install tauri-cli"
    if cargo install tauri-cli; then
        log_message "SUCCESS" "Tauri CLI installed."
        log_version "Tauri" "" tauri
    else
        log_message "ERROR" "Failed to install Tauri CLI."
        return 1
    fi
}

# --- Deno ---
install_deno() {
    if command -v deno &> /dev/null; then
        log_message "WARN" "Deno is already installed."
        return
    fi

    confirm_install "Deno" "deno" || return

    case $DISTRO in
        debian|fedora)
            _verbose_cmd "curl -fsSL https://deno.land/install.sh | sh"
            curl -fsSL https://deno.land/install.sh | sh
            export PATH="$HOME/.deno/bin:$PATH"
            ;;
        arch)
            pkg_install_native deno
            ;;
    esac

    if command -v deno &> /dev/null; then
        log_message "SUCCESS" "Deno installed."
        log_version "Deno" deno deno
    else
        log_message "ERROR" "Deno installation failed."
    fi
}

# --- Bun ---
install_bun() {
    if command -v bun &> /dev/null; then
        log_message "WARN" "Bun is already installed."
        return
    fi

    confirm_install "Bun" "bun" || return

    _verbose_cmd "curl -fsSL https://bun.sh/install | bash"
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"

    if command -v bun &> /dev/null; then
        log_message "SUCCESS" "Bun installed."
        log_version "Bun" bun bun
    else
        log_message "ERROR" "Bun installation failed."
    fi
}

install_frameworks() { _install_list "Frameworks" FRAMEWORKS_LIST; }

check_frameworks_installations() {
    _check_installations FRAMEWORKS_LIST \
        "Flutter:flutter" "React Native:npx" "Next.js:npx" \
        "Node.js (Latest):node" "Electron:electron" "Tauri:tauri" \
        "Deno:deno" "Bun:bun"
}