#!/usr/bin/env bash
# id: proton_pass
# name: Proton Pass
# desc: Proton Pass password manager.
# method: apt
# pkg: proton-pass
# tags: privacy,passwords

install_proton_pass() {
    if command -v proton-pass &> /dev/null || command -v protonpass &> /dev/null; then
        log_message "WARN" "Proton Pass is already installed."
        return
    fi
    confirm_install "Proton Pass" "" || return

    case $DISTRO in
        debian)
            if command -v flatpak &> /dev/null; then
                _flatpak_install "Proton Pass" "me.proton.Pass" "proton-pass"
            else
                _check_deps "Proton Pass" "curl" "wget"
                log_message "INFO" "Downloading latest Proton Pass .deb..."
                if wget --progress=bar:force -O /tmp/ProtonPass.deb "https://proton.me/download/pass/ProtonPass.deb"; then
                    dpkg -i /tmp/ProtonPass.deb || apt install -f -y
                    rm -f /tmp/ProtonPass.deb
                    log_message "SUCCESS" "Proton Pass installed via .deb."
                else
                    log_message "INFO" "Fallback to Flatpak for Proton Pass..."
                    install_with_fallback "Proton Pass" "" "" "me.proton.Pass" "proton-pass"
                fi
            fi
            ;;
        arch)
            install_with_fallback "Proton Pass" "" "proton-pass-bin" "me.proton.Pass" "proton-pass"
            return $?
            ;;
        fedora)
            _check_deps "Proton Pass" "curl" "wget"
            log_message "INFO" "Downloading latest Proton Pass .rpm..."
            if wget --progress=bar:force -O /tmp/ProtonPass.rpm "https://proton.me/download/pass/ProtonPass.rpm"; then
                dnf install -y /tmp/ProtonPass.rpm
                rm -f /tmp/ProtonPass.rpm
                log_message "SUCCESS" "Proton Pass installed via .rpm."
            else
                install_with_fallback "Proton Pass" "" "" "me.proton.Pass" "proton-pass"
            fi
            ;;
    esac
    log_version "Proton Pass" "" "proton-pass"
}
