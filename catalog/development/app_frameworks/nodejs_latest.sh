#!/usr/bin/env bash
# id: nodejs_latest
# name: Node.js (Latest)
# desc: Node.js latest.
# method: apt
# pkg: node
# tags: dev,framework

install_nodejs_latest() {
    if command -v node &> /dev/null; then
        local current_version
        current_version=$(node --version)
        log_message "INFO" "Node.js is already installed ($current_version)."
        log_message "INFO" "This will install the latest LTS version via NodeSource."
    fi

    confirm_install "Node.js (Latest LTS)" "nodejs" || return

    case $DISTRO in
        debian)
            _verbose_cmd "curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -"
            curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
            _verbose_cmd "apt install -y -V nodejs"
            apt install -y -V nodejs
            ;;
        arch)
            pkg_install_native nodejs npm
            ;;
        fedora)
            _verbose_cmd "curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash -"
            curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash -
            _verbose_cmd "dnf install -y nodejs"
            dnf install -y nodejs
            ;;
    esac

    log_message "SUCCESS" "Node.js LTS installed."
    log_version "Node.js" nodejs node
}
