# id: dirsearch
# name: Discovery
# desc: Web directory brute force.
# method: python
# pkg: dirsearch
# tags: security,web

install_dirsearch() {
    if command -v dirsearch &> /dev/null; then
        log_message "WARN" "dirsearch is already installed."
        return
    fi
    confirm_install "dirsearch" "dirsearch" || return
    log_message "INFO" "dirsearch is a Python tool. Checking for pip..."
    _install_with_pip_fallback "dirsearch" "dirsearch" "dirsearch"
}
