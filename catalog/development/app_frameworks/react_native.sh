# id: react_native
# name: React Native
# desc: React Native.
# method: snap
# pkg: react-native
# tags: dev,framework

install_react_native() {
    if command -v npx &> /dev/null && npx react-native --version &> /dev/null; then
        log_message "WARN" "React Native CLI is already available."
        return
    fi

    confirm_install "React Native" "" "Requires Node.js and npm" || return

    if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
        log_message "ERROR" "Node.js and npm are required. Install Node.js first."
        return 1
    fi

    log_message "INFO" "Installing React Native CLI globally..."
    _verbose_cmd "npm install -g @react-native-community/cli"
    if npm install -g @react-native-community/cli; then
        log_message "SUCCESS" "React Native CLI installed."
        log_version "React Native" "" "react-native"
    else
        log_message "ERROR" "Failed to install React Native CLI."
        return 1
    fi
}
