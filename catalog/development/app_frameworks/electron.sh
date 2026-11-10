# id: electron
# name: Electron
# desc: Electron framework.
# method: apt
# pkg: electron
# tags: dev,framework

install_electron() {
    if command -v electron &> /dev/null; then
        log_message "WARN" "Electron is already installed."
        return
    fi

    confirm_install "Electron" "" "Requires Node.js and npm" || return

    if ! command -v npm &> /dev/null; then
        log_message "ERROR" "npm is required. Install Node.js first."
        return 1
    fi

    log_message "INFO" "Installing Electron globally..."
    _verbose_cmd "npm install -g electron"
    if npm install -g electron; then
        log_message "SUCCESS" "Electron installed."
        log_version "Electron" "" electron
    else
        log_message "ERROR" "Failed to install Electron."
        return 1
    fi
}
