#!/usr/bin/env bash
# id: hashcat
# name: Offline cracking
# desc: GPU password cracking.
# method: cuda
# pkg: hashcat
# tags: security,creds

install_hashcat() {
    if command -v hashcat &> /dev/null; then
        log_message "WARN" "hashcat is already installed."
        return
    fi
    confirm_install "hashcat" "hashcat" || return
    install_with_fallback "hashcat" "hashcat" "hashcat" "" "hashcat"
    _verify_install "hashcat" hashcat
}
