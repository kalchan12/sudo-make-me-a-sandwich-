#!/usr/bin/env bash
# id: redshift
# name: Redshift
# desc: Display color temperature adjuster.
# method: apt
# pkg: redshift
# tags: app,desktop

install_redshift() {
    if command -v redshift &> /dev/null; then
        log_message "WARN" "Redshift is already installed."
        return
    fi
    confirm_install "Redshift" "redshift" || return
    case $DISTRO in
        debian)
            _check_deps "Redshift (GUI)" "redshift-gtk"
            ;;
    esac
    install_with_fallback "Redshift" "redshift" "redshift" "" "redshift"
    log_version "Redshift" redshift
}
