#!/usr/bin/env bash
# id: obs_studio
# name: OBS Studio
# desc: Screen recording and streaming.
# method: apt
# pkg: obs-studio
# tags: app,media

install_obs_studio() {
    if command -v obs &> /dev/null; then
        log_message "WARN" "OBS Studio is already installed."
        return
    fi
    confirm_install "OBS Studio" "obs-studio" || return
    case $DISTRO in
        debian)
            _check_deps "OBS Studio (recommended)" "libavcodec-extra"
            ;;
    esac
    install_with_fallback "OBS Studio" "obs-studio" "obs-studio" "com.obsproject.Studio" "obs"
    log_version "OBS Studio" obs
}
