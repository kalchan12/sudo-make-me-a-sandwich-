# id: binwalk
# name: Reverse engineering
# desc: Firmware analysis.
# method: python
# pkg: binwalk
# tags: security,re

install_binwalk() {
    if command -v binwalk &> /dev/null; then
        log_message "WARN" "binwalk is already installed."
        return
    fi
    confirm_install "binwalk" "binwalk" || return
    install_with_fallback "binwalk" "binwalk" "binwalk" "" "binwalk"
    _verify_install "binwalk" binwalk
}
