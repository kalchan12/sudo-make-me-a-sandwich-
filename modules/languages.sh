#!/bin/bash

# ==============================================================================
# Programming Languages Module
# ==============================================================================

LANGUAGES_LIST=(
    "Python|install_python|python3"
    "Node.js|install_nodejs|nodejs"
    "TypeScript|install_typescript|"
    "Go|install_go|golang"
    "Rust|install_rust|rust"
    "Java (OpenJDK)|install_java|default-jdk"
    "C/C++ (GCC)|install_gcc|build-essential"
    "C# (.NET)|install_dotnet|dotnet-sdk"
    "Ruby|install_ruby|ruby"
    "PHP|install_php|php"
    "Lua|install_lua|lua"
    "R|install_r|r-base"
    "Zig|install_zig|zig"
    "Dart|install_dart|dart"
    "Kotlin|install_kotlin|kotlin"
)

install_python() {
    if command -v python3 &> /dev/null; then
        log_message "WARN" "Python is already installed."
        return
    fi
    confirm_install "Python" "python3" || return
    case $DISTRO in
        debian) pkg_install_native python3 python3-pip ;;
        arch) pkg_install_native python python-pip ;;
        fedora) pkg_install_native python3 python3-pip ;;
    esac
    log_message "SUCCESS" "Python installed."
    log_version "Python" python3 python3
}

install_nodejs() {
    if command -v node &> /dev/null; then
        log_message "WARN" "Node.js is already installed."
        return
    fi
    confirm_install "Node.js" "nodejs" || return
    case $DISTRO in
        debian)
            curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
            apt install -y -V nodejs
            ;;
        arch) pkg_install_native nodejs npm ;;
        fedora) pkg_install_native nodejs npm ;;
    esac
    log_message "SUCCESS" "Node.js installed."
    log_version "Node.js" nodejs node
}

install_typescript() {
    if command -v tsc &> /dev/null; then
        log_message "WARN" "TypeScript is already installed."
        return
    fi
    confirm_install "TypeScript" "" || return
    _check_deps "TypeScript" node npm || return
    if command -v npm &> /dev/null; then
        npm install -g typescript
        log_message "SUCCESS" "TypeScript installed."
        log_version "TypeScript" typescript tsc
    else
        log_message "ERROR" "npm is not available. Install Node.js first."
    fi
}

install_go() {
    if command -v go &> /dev/null; then
        log_message "WARN" "Go is already installed."
        return
    fi
    confirm_install "Go" "golang" || return
    case $DISTRO in
        debian|fedora) pkg_install_native golang ;;
        arch) pkg_install_native go ;;
    esac
    log_message "SUCCESS" "Go installed."
    log_version "Go" golang go
}

install_rust() {
    if command -v rustc &> /dev/null; then
        log_message "WARN" "Rust is already installed."
        return
    fi
    confirm_install "Rust" "rust" || return
    if command -v rustup &> /dev/null; then
        rustup install stable
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        # shellcheck source=dev/null
        . "$HOME/.cargo/env"
    fi
    log_message "SUCCESS" "Rust installed."
    log_version "Rust" rust rustc
}

install_java() {
    if command -v java &> /dev/null; then
        log_message "WARN" "Java is already installed."
        return
    fi
    confirm_install "Java (OpenJDK)" "default-jdk" || return
    case $DISTRO in
        debian) pkg_install_native default-jdk ;;
        arch) pkg_install_native jdk-openjdk ;;
        fedora) pkg_install_native java-latest-openjdk ;;
    esac
    log_message "SUCCESS" "Java installed."
    log_version "Java" default-jdk java
}

install_gcc() {
    if command -v gcc &> /dev/null && command -v g++ &> /dev/null; then
        log_message "WARN" "GCC is already installed."
        return
    fi
    confirm_install "C/C++ (GCC)" "build-essential" || return
    case $DISTRO in
        debian) pkg_install_native build-essential ;;
        arch) pkg_install_native base-devel ;;
        fedora) pkg_install_native gcc gcc-c++ make ;;
    esac
    log_message "SUCCESS" "GCC installed."
    log_version "GCC" build-essential gcc
}

install_dotnet() {
    if command -v dotnet &> /dev/null; then
        log_message "WARN" ".NET SDK is already installed."
        return
    fi
    confirm_install "C# (.NET)" "dotnet-sdk" || return
    case $DISTRO in
        debian)
            wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
            dpkg -i /tmp/packages-microsoft-prod.deb && rm -f /tmp/packages-microsoft-prod.deb
            apt update && apt install -y -V dotnet-sdk-8.0
            ;;
        arch) pkg_install_native dotnet-sdk ;;
        fedora) pkg_install_native dotnet-sdk-8.0 ;;
    esac
    log_message "SUCCESS" ".NET SDK installed."
    log_version ".NET" dotnet-sdk dotnet
}

install_ruby() {
    if command -v ruby &> /dev/null; then
        log_message "WARN" "Ruby is already installed."
        return
    fi
    confirm_install "Ruby" "ruby" || return
    pkg_install_native ruby
    log_message "SUCCESS" "Ruby installed."
    log_version "Ruby" ruby
}

install_php() {
    if command -v php &> /dev/null; then
        log_message "WARN" "PHP is already installed."
        return
    fi
    confirm_install "PHP" "php" || return
    pkg_install_native php
    log_message "SUCCESS" "PHP installed."
    log_version "PHP" php
}

install_lua() {
    if command -v lua &> /dev/null; then
        log_message "WARN" "Lua is already installed."
        return
    fi
    confirm_install "Lua" "lua" || return
    install_with_fallback "Lua" "lua" "lua" "" "lua"
}

install_r() {
    if command -v R &> /dev/null; then
        log_message "WARN" "R is already installed."
        return
    fi
    confirm_install "R" "r-base" || return
    case $DISTRO in
        debian) pkg_install_native r-base ;;
        arch) pkg_install_native r ;;
        fedora) pkg_install_native R ;;
    esac
    log_message "SUCCESS" "R installed."
    log_version "R" r-base R
}

install_zig() {
    if command -v zig &> /dev/null; then
        log_message "WARN" "Zig is already installed."
        return
    fi
    confirm_install "Zig" "zig" || return
    install_with_fallback "Zig" "zig" "zig" "" "zig"
}

install_dart() {
    if command -v dart &> /dev/null; then
        log_message "WARN" "Dart is already installed."
        return
    fi
    confirm_install "Dart" "dart" || return
    if pkg_is_available dart; then
        pkg_install_native dart
    else
        wget -qO /etc/apt/sources.list.d/dart_stable.list https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list
        apt update && apt install -y -V dart
    fi
    log_message "SUCCESS" "Dart installed."
    log_version "Dart" dart
}

install_kotlin() {
    if command -v kotlin &> /dev/null; then
        log_message "WARN" "Kotlin is already installed."
        return
    fi
    confirm_install "Kotlin" "kotlin" || return
    install_with_fallback "Kotlin" "kotlin" "kotlin" "" "kotlin"
}

# --- Languages Menu ---

show_languages_menu() {
    echo -e "\n${YELLOW}-- Programming Languages --${NC}"
    local i=1
    for info in "${LANGUAGES_LIST[@]}"; do
        local name="${info%%|*}"
        echo "$i) Install $name"
        ((i++))
    done
    local all_idx=$i
    echo "$all_idx) Install All Languages"
    local back_idx=$((all_idx + 1))
    echo "$back_idx) Back"
    echo -e "${CYAN}Enter a number to install, or e<N> for details (e.g., e1)${NC}"
    echo -n "Select option: "
    read -r lang_choice
    if [[ "$lang_choice" =~ ^e([0-9]+)$ ]]; then
        _explain_by_index LANGUAGES_LIST "${BASH_REMATCH[1]}"
        show_languages_menu
        return
    elif [ "$lang_choice" = "all" ] || [ "$lang_choice" = "$all_idx" ]; then
        install_all_languages
    elif [ "$lang_choice" = "$back_idx" ]; then
        show_main_menu
        return
    elif [[ "$lang_choice" =~ ^[0-9]+$ ]] && [ "$lang_choice" -ge 1 ] && [ "$lang_choice" -lt "$all_idx" ]; then
        local idx=0
        for info in "${LANGUAGES_LIST[@]}"; do
            if [ "$idx" -eq $((lang_choice - 1)) ]; then
                local call="${info#*|}"
                call="${call%%|*}"
                $call
                break
            fi
            ((idx++))
        done
    else
        log_message "WARN" "Invalid option"
        show_languages_menu
        return
    fi
    show_main_menu
}

install_all_languages() { _install_list "Languages" LANGUAGES_LIST; }
