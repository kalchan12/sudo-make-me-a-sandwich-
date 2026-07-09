#!/bin/bash

# ==============================================================================
# Dev Tools Module — CLI utilities, system tools, media & productivity
# ==============================================================================

# Format: "Display Name|function_call|pkg_name_for_size"
DEV_TOOLS_LIST=(
    "tmux|install_tmux|tmux"
    "Neovim|install_neovim|neovim"
    "Docker|install_docker|docker.io"
    "jq|install_jq|jq"
    "ripgrep|install_ripgrep|ripgrep"
    "fzf|install_fzf|fzf"
    "bat|install_bat|bat"
    "fd|install_fd|fd-find"
    "btop|install_btop|btop"
    "lazygit|install_lazygit|lazygit"
    "zoxide|install_zoxide|zoxide"
    "delta|install_delta|git-delta"
    "tldr|install_tldr|tldr"
    "httpie|install_httpie|httpie"
    "glances|install_glances|glances"
    "thefuck|install_thefuck|thefuck"
    "eza|install_eza|eza"
    "dust|install_dust|dust"
    "Flameshot|install_flameshot|flameshot"
    "KeePassXC|install_keepassxc|keepassxc"
    "mpv|install_mpv|mpv"
    "Syncthing|install_syncthing|syncthing"
    "VLC|install_vlc|vlc"
)

# --- CLI Essentials ---

install_tmux() {
    if command -v tmux &> /dev/null; then
        log_message "WARN" "tmux is already installed."
        return
    fi
    confirm_install "tmux" "tmux" || return
    install_with_fallback "tmux" "tmux" "tmux" "" "tmux"
}

install_neovim() {
    if command -v nvim &> /dev/null; then
        log_message "WARN" "Neovim is already installed."
        return
    fi
    confirm_install "Neovim" "neovim" || return
    install_with_fallback "Neovim" "neovim" "neovim" "io.neovim.nvim" "nvim"
}

install_jq() {
    if command -v jq &> /dev/null; then
        log_message "WARN" "jq is already installed."
        return
    fi
    confirm_install "jq" "jq" || return
    install_with_fallback "jq" "jq" "jq" "" "jq"
}

install_ripgrep() {
    if command -v rg &> /dev/null; then
        log_message "WARN" "ripgrep is already installed."
        return
    fi
    confirm_install "ripgrep" "ripgrep" || return
    install_with_fallback "ripgrep" "ripgrep" "ripgrep" "" "rg"
}

install_fzf() {
    if command -v fzf &> /dev/null; then
        log_message "WARN" "fzf is already installed."
        return
    fi
    confirm_install "fzf" "fzf" || return
    install_with_fallback "fzf" "fzf" "fzf" "" "fzf"
}

install_bat() {
    if command -v bat &> /dev/null || command -v batcat &> /dev/null; then
        log_message "WARN" "bat is already installed."
        return
    fi
    confirm_install "bat" "bat" || return
    install_with_fallback "bat" "bat" "bat" "" "bat"
}

install_fd() {
    if command -v fd &> /dev/null || command -v fdfind &> /dev/null; then
        log_message "WARN" "fd is already installed."
        return
    fi
    confirm_install "fd" "fd" || return
    case $DISTRO in
        arch) pkg_install_native fd ;;
        debian|fedora) pkg_install_native fd-find ;;
    esac
    log_message "SUCCESS" "fd installed."
    log_version "fd" "fd-find" "fd"
}

install_eza() {
    if command -v eza &> /dev/null; then
        log_message "WARN" "eza is already installed."
        return
    fi
    confirm_install "eza" "eza" || return
    install_with_fallback "eza" "eza" "eza" "io.github.eza-community.eza" "eza"
}

install_zoxide() {
    if command -v zoxide &> /dev/null; then
        log_message "WARN" "zoxide is already installed."
        return
    fi
    confirm_install "zoxide" "zoxide" || return
    install_with_fallback "zoxide" "zoxide" "zoxide" "" "zoxide"
}

install_delta() {
    if command -v delta &> /dev/null; then
        log_message "WARN" "delta is already installed."
        return
    fi
    confirm_install "delta" "git-delta" || return
    install_with_fallback "delta" "git-delta" "git-delta" "" "delta"
}

install_tldr() {
    if command -v tldr &> /dev/null; then
        log_message "WARN" "tldr is already installed."
        return
    fi
    confirm_install "tldr" "tldr" || return
    install_with_fallback "tldr" "tldr" "tldr" "" "tldr"
}

install_httpie() {
    if command -v http &> /dev/null; then
        log_message "WARN" "httpie is already installed."
        return
    fi
    confirm_install "httpie" "httpie" || return
    install_with_fallback "httpie" "httpie" "httpie" "" "http"
}

install_thefuck() {
    if command -v thefuck &> /dev/null; then
        log_message "WARN" "thefuck is already installed."
        return
    fi
    confirm_install "thefuck" "thefuck" || return
    _check_deps "thefuck" python3 python3-pip || return
    if pkg_is_available thefuck; then
        pkg_install_native thefuck
    elif command -v pip3 &> /dev/null; then
        pip3 install thefuck
    elif command -v pip &> /dev/null; then
        pip install thefuck
    else
        log_message "ERROR" "thefuck is not available in repos. Install python3-pip and try again."
        return
    fi
    log_message "SUCCESS" "thefuck installed."
    log_version "thefuck" thefuck
}

install_dust() {
    if command -v dust &> /dev/null; then
        log_message "WARN" "dust is already installed."
        return
    fi
    confirm_install "dust" "dust" || return
    case $DISTRO in
        debian) pkg_install_native du-dust ;;
        arch|fedora) pkg_install_native dust ;;
    esac
    log_message "SUCCESS" "dust installed."
    log_version "dust" dust
}

# --- Dev Platforms ---

install_docker() {
    if command -v docker &> /dev/null; then
        log_message "WARN" "Docker is already installed."
        return
    fi
    confirm_install "Docker" "docker" || return
    case $DISTRO in
        debian) pkg_install_native docker.io ;;
        arch|fedora) pkg_install_native docker ;;
    esac
    log_message "SUCCESS" "Docker installed."
    log_version "Docker" docker
}

# --- System Monitors ---

install_btop() {
    if command -v btop &> /dev/null; then
        log_message "WARN" "btop is already installed."
        return
    fi
    confirm_install "btop" "btop" || return
    install_with_fallback "btop" "btop" "btop" "net.btop.btop" "btop"
}

install_glances() {
    if command -v glances &> /dev/null; then
        log_message "WARN" "glances is already installed."
        return
    fi
    confirm_install "glances" "glances" || return
    install_with_fallback "glances" "glances" "glances" "" "glances"
}

# --- Git Tools ---

install_lazygit() {
    if command -v lazygit &> /dev/null; then
        log_message "WARN" "lazygit is already installed."
        return
    fi
    confirm_install "lazygit" "lazygit" || return
    install_with_fallback "lazygit" "lazygit" "lazygit" "io.github.jesseduffield.lazygit" "lazygit"
}

# --- Media & Productivity ---

install_vlc() {
    if command -v vlc &> /dev/null; then
        log_message "WARN" "VLC is already installed."
        return
    fi
    confirm_install "VLC" "vlc" || return
    install_with_fallback "VLC" "vlc" "vlc" "org.videolan.VLC" "vlc"
}

install_mpv() {
    if command -v mpv &> /dev/null; then
        log_message "WARN" "mpv is already installed."
        return
    fi
    confirm_install "mpv" "mpv" || return
    install_with_fallback "mpv" "mpv" "mpv" "io.mpv.Mpv" "mpv"
}

install_flameshot() {
    if command -v flameshot &> /dev/null; then
        log_message "WARN" "Flameshot is already installed."
        return
    fi
    confirm_install "Flameshot" "flameshot" || return
    install_with_fallback "Flameshot" "flameshot" "flameshot" "org.flameshot.Flameshot" "flameshot"
}

install_keepassxc() {
    if command -v keepassxc &> /dev/null; then
        log_message "WARN" "KeePassXC is already installed."
        return
    fi
    confirm_install "KeePassXC" "keepassxc" || return
    install_with_fallback "KeePassXC" "keepassxc" "keepassxc" "org.keepassxc.KeePassXC" "keepassxc"
}

install_syncthing() {
    if command -v syncthing &> /dev/null; then
        log_message "WARN" "Syncthing is already installed."
        return
    fi
    confirm_install "Syncthing" "syncthing" || return
    install_with_fallback "Syncthing" "syncthing" "syncthing" "" "syncthing"
}

# --- Dev Tools Menu ---

show_dev_tools_menu() {
    while true; do
        echo -e "\n${PURPLE}── Dev Tools ──${NC}"
        local i=1
        for info in "${DEV_TOOLS_LIST[@]}"; do
            local name="${info%%|*}"
            gecho "$i) Install $name"
            ((i++))
        done
        local all_idx=$i
        gecho "$all_idx) Install All"
        local back_idx=$((all_idx + 1))
        gecho "$back_idx) Back"
        echo -e "${PURPLE}Enter a number to install, or e<N> for details (e.g., e1)${NC}"
        echo -n -e "${PURPLE}Select option: ${NC}"
        read -r dt_choice
        if [[ "$dt_choice" =~ ^e([0-9]+)$ ]]; then
            _explain_by_index DEV_TOOLS_LIST "${BASH_REMATCH[1]}"
            continue
        elif [ "$dt_choice" = "all" ] || [ "$dt_choice" = "$all_idx" ]; then
            install_dev_tools
        elif [ "$dt_choice" = "$back_idx" ]; then
            show_main_menu; return
        elif [[ "$dt_choice" =~ ^[0-9]+$ ]] && [ "$dt_choice" -ge 1 ] && [ "$dt_choice" -lt "$all_idx" ]; then
            local idx=0
            for info in "${DEV_TOOLS_LIST[@]}"; do
                if [ "$idx" -eq $((dt_choice - 1)) ]; then
                    local call="${info#*|}"
                    call="${call%%|*}"
                    $call
                    break
                fi
                ((idx++))
            done
        else
            log_message "WARN" "Invalid option"
        fi
    done
}

install_dev_tools() { _install_list "Dev Tools" DEV_TOOLS_LIST; }
