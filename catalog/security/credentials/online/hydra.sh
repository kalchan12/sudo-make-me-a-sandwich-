#!/usr/bin/env bash
# id: hydra
# name: Online attacks
# desc: Online password cracking.
# method: go
# pkg: hydra
# tags: security,creds

install_hydra() {
    if command -v hydra &> /dev/null; then
        log_message "WARN" "hydra is already installed."
        return
    fi
    confirm_install "hydra" "hydra" || return
    install_with_fallback "hydra" "hydra" "hydra" "" "hydra"
    _verify_install "hydra" hydra
}
