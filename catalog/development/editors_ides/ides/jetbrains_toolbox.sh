# id: jetbrains_toolbox
# name: JetBrains Toolbox
# desc: JetBrains Toolbox IDE manager.
# method: url
# pkg: jetbrains-toolbox
# tags: dev,ide

install_jetbrains_toolbox() {
    if command -v jetbrains-toolbox &> /dev/null || [ -d "/opt/jetbrains-toolbox" ]; then
        log_message "WARN" "JetBrains Toolbox is already installed."
        return
    fi
    confirm_install "JetBrains Toolbox" "" "Download from jetbrains.com" || return

    _verbose_cmd "wget -O /tmp/jetbrains-toolbox.tar.gz https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.4.40621.tar.gz"
    if ! wget --progress=bar:force -O /tmp/jetbrains-toolbox.tar.gz "https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.4.40621.tar.gz"; then
        log_message "ERROR" "Failed to download JetBrains Toolbox"
        rm -f /tmp/jetbrains-toolbox.tar.gz
        return
    fi
    mkdir -p /opt/jetbrains-toolbox
    tar xzf /tmp/jetbrains-toolbox.tar.gz -C /opt/jetbrains-toolbox --strip-components=1
    chmod +x /opt/jetbrains-toolbox/jetbrains-toolbox
    ln -sf /opt/jetbrains-toolbox/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox
    rm -f /tmp/jetbrains-toolbox.tar.gz
    log_message "SUCCESS" "JetBrains Toolbox installed."
}
