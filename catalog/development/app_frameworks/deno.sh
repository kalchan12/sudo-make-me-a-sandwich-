#!/usr/bin/env bash
# id: deno
# name: Deno
# desc: Deno runtime.
# method: apt
# pkg: deno
# tags: dev,framework

install_deno() {
    if command -v deno &> /dev/null; then
        log_message "WARN" "Deno is already installed."
        return
    fi

    confirm_install "Deno" "deno" || return

    case $DISTRO in
        debian|fedora)
            _verbose_cmd "curl -fsSL https://deno.land/install.sh | sh"
            curl -fsSL https://deno.land/install.sh | sh
            export PATH="$HOME/.deno/bin:$PATH"
            ;;
        arch)
            pkg_install_native deno
            ;;
    esac

    if command -v deno &> /dev/null; then
        log_message "SUCCESS" "Deno installed."
        log_version "Deno" deno deno
    else
        log_message "ERROR" "Deno installation failed."
    fi
}
