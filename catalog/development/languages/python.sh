#!/usr/bin/env bash
# id: python
# name: Python
# desc: Python runtime.
# method: apt
# pkg: python3
# tags: lang

install_python() {
    if command -v python3 &> /dev/null; then
        log_message "WARN" "Python is already installed."
        return
    fi
    confirm_install "Python" "python3" || return
    case $DISTRO in
        debian) pkg_install_native python3 python3-pip ;;
        arch) pkg_install_native python python-pip ;;
        fedora) pkg_install_native python3 python3-pip ;;
    esac
    log_message "SUCCESS" "Python installed."
    log_version "Python" python3 python3
}
