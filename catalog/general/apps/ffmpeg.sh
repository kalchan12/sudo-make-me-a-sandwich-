#!/usr/bin/env bash
# id: ffmpeg
# name: ffmpeg
# desc: Multimedia framework.
# method: apt
# pkg: ffmpeg
# tags: app,media

install_ffmpeg() {
    if command -v ffmpeg &> /dev/null; then
        log_message "WARN" "ffmpeg is already installed."
        return
    fi
    confirm_install "ffmpeg" "ffmpeg" || return
    install_with_fallback "ffmpeg" "ffmpeg" "ffmpeg" "org.ffmpeg.ffmpeg" "ffmpeg"
    log_version "ffmpeg" ffmpeg
}
