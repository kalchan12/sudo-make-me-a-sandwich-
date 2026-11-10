# id: whatweb
# name: Fingerprinting
# desc: Web fingerprinting.
# method: go
# pkg: whatweb
# tags: security,recon

install_whatweb() {
    if command -v whatweb &> /dev/null; then
        log_message "WARN" "whatweb is already installed."
        return
    fi
    confirm_install "whatweb" "whatweb" || return
    install_with_fallback "whatweb" "whatweb" "whatweb" "" "whatweb"
    _verify_install "whatweb" whatweb
}
