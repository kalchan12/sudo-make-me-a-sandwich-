# id: vlc
# name: VLC
# desc: VLC media player.
# method: apt
# pkg: vlc
# tags: app,media

install_vlc() {
    if command -v vlc &> /dev/null; then
        log_message "WARN" "VLC is already installed."
        return
    fi
    confirm_install "VLC" "vlc" || return
    install_with_fallback "VLC" "vlc" "vlc" "org.videolan.VLC" "vlc"
}
