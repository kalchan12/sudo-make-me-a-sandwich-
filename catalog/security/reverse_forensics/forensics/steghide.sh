# id: steghide
# name: Stego & metadata
# desc: Steganography.
# method: python
# pkg: steghide
# tags: security,forensics

install_steghide() {
    if command -v steghide &> /dev/null; then
        log_message "WARN" "steghide is already installed."
        return
    fi
    confirm_install "steghide" "steghide" || return
    install_with_fallback "steghide" "steghide" "steghide" "" "steghide"
    _verify_install "steghide" steghide
}
