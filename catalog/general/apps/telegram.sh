# id: telegram
# name: Telegram
# desc: Telegram desktop client.
# method: apt
# pkg: telegram-desktop
# tags: app,comm

install_telegram() {
    if command -v telegram-desktop &> /dev/null; then
        log_message "WARN" "Telegram is already installed."
        return
    fi
    confirm_install "Telegram" "telegram-desktop" || return
    install_with_fallback "Telegram" "telegram-desktop" "telegram-desktop" "org.telegram.desktop" "telegram-desktop"
    log_version "Telegram" telegram-desktop
}
