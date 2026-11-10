# id: theharvester
# name: OSINT
# desc: OSINT gathering.
# method: go
# pkg: theharvester
# tags: security,osint

install_theharvester() {
    if command -v theHarvester &> /dev/null; then
        log_message "WARN" "theHarvester is already installed."
        return
    fi
    confirm_install "theHarvester" "theharvester" || return
    install_with_fallback "theHarvester" "theharvester" "theharvester" "" "theHarvester"
    _verify_install "theHarvester" theHarvester
}
