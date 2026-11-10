# id: yt_dlp
# name: yt-dlp
# desc: YouTube media downloader.
# method: apt
# pkg: yt-dlp
# tags: app,media

install_yt_dlp() {
    if command -v yt-dlp &> /dev/null; then
        log_message "WARN" "yt-dlp is already installed."
        return
    fi
    confirm_install "yt-dlp" "yt-dlp" || return
    install_with_fallback "yt-dlp" "yt-dlp" "yt-dlp" "" "yt-dlp"
    log_version "yt-dlp" yt-dlp
}
