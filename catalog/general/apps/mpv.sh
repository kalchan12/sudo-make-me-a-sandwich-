# id: mpv
# name: mpv
# desc: Media player.
# method: apt
# pkg: mpv
# tags: app,media

install_mpv() {
    if command -v mpv &> /dev/null; then
        log_message "WARN" "mpv is already installed."
        return
    fi
    confirm_install "mpv" "mpv" || return
    install_with_fallback "mpv" "mpv" "mpv" "io.mpv.Mpv" "mpv"
}
