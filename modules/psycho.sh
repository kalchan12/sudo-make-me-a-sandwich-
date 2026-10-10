#!/bin/bash
# ==============================================================================
# Module: Psycho
# Description: Psycho's personalized essentials & hacker Kitty environment
# ==============================================================================

PSYCHO_LIST=(
    "Kitty (Hacker Suite)|install_kitty_psycho|kitty"
    "Brave|install_brave|brave-browser"
    "WPS Office|install_wps|wps"
    "OBS Studio|install_obs_studio|obs-studio"
    "ffmpeg|install_ffmpeg|ffmpeg"
    "yt-dlp|install_yt_dlp|yt-dlp"
    "Redshift|install_redshift|redshift"
)

show_psycho_menu() {
    _render_menu PSYCHO_LIST "Psycho" \
        install_psycho check_psycho_installations show_main_menu
}

install_kitty_psycho() {
    log_message "INFO" "Installing Kitty Terminal & Hacker Configs..."

    # 1. Install Kitty binary if not present
    if ! command -v kitty &> /dev/null; then
        install_kitty
    else
        log_message "INFO" "Kitty binary is already installed."
    fi

    # 2. Deploy Kitty hacker configs, themes, and Zsh prediction/highlighting suite
    local script_root
    script_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    if [ -f "$script_root/kitty-config/install.sh" ]; then
        log_message "INFO" "Applying Kitty modular hacker themes, Oh My Zsh, and predictions..."
        bash "$script_root/kitty-config/install.sh"
    elif [ -f "$HOME/.sudo-make-me-a-sandwich/kitty-config/install.sh" ]; then
        log_message "INFO" "Applying Kitty modular hacker themes from installed directory..."
        bash "$HOME/.sudo-make-me-a-sandwich/kitty-config/install.sh"
    fi

    log_message "SUCCESS" "Kitty Terminal & Hacker Configs installed and configured!"
}

install_psycho() { _install_list "Psycho" PSYCHO_LIST; }

check_psycho_installations() {
    _check_installations PSYCHO_LIST \
        "Kitty (Hacker Suite):kitty" "Brave:brave-browser" "WPS Office:wps" \
        "OBS Studio:obs" "ffmpeg:ffmpeg" "yt-dlp:yt-dlp" "Redshift:redshift"
}
