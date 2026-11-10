#!/usr/bin/env bash
# id: nodejs
# name: Node.js
# desc: Node.js runtime.
# method: apt
# pkg: nodejs
# tags: lang

install_nodejs() {
    if command -v node &> /dev/null; then
        log_message "WARN" "Node.js is already installed."
        return
    fi
    confirm_install "Node.js" "nodejs" || return
    case $DISTRO in
        debian)
            _verbose_cmd "curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -"
            curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
            _verbose_cmd "apt install -y -V nodejs"
            apt install -y -V nodejs
            ;;
        arch) pkg_install_native nodejs npm ;;
        fedora) pkg_install_native nodejs npm ;;
    esac
    log_message "SUCCESS" "Node.js installed."
    log_version "Node.js" nodejs node
}
