# id: syncthing
# name: Syncthing
# desc: File synchronization.
# method: apt
# pkg: syncthing
# tags: app,desktop

install_syncthing() {
    if command -v syncthing &> /dev/null; then
        log_message "WARN" "Syncthing is already installed."
        return
    fi
    confirm_install "Syncthing" "syncthing" || return
    install_with_fallback "Syncthing" "syncthing" "syncthing" "" "syncthing"
}
