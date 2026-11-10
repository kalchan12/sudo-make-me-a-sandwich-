#!/usr/bin/env bash
# id: gcc
# name: C/C++ (GCC)
# desc: C/C++ toolchain.
# method: apt
# pkg: build-essential
# tags: lang

install_gcc() {
    if command -v gcc &> /dev/null && command -v g++ &> /dev/null; then
        log_message "WARN" "GCC is already installed."
        return
    fi
    confirm_install "C/C++ (GCC)" "build-essential" || return
    case $DISTRO in
        debian) pkg_install_native build-essential ;;
        arch) pkg_install_native base-devel ;;
        fedora) pkg_install_native gcc gcc-c++ make ;;
    esac
    log_message "SUCCESS" "GCC installed."
    log_version "GCC" build-essential gcc
}
