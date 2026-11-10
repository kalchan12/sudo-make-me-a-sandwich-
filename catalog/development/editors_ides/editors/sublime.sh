#!/usr/bin/env bash
# id: sublime
# name: Sublime Text
# desc: Sublime Text editor.
# method: apt
# pkg: sublime-text
# tags: dev,editor

install_sublime() {
    if command -v subl &> /dev/null; then
        log_message "WARN" "Sublime Text is already installed."
        return
    fi
    confirm_install "Sublime Text" "" "Download from sublimetext.com" || return

    case $DISTRO in
        debian)
            _verbose_cmd "wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /usr/share/keyrings/sublimetext.gpg"
            wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /usr/share/keyrings/sublimetext.gpg
            echo "deb [signed-by=/usr/share/keyrings/sublimetext.gpg] https://download.sublimetext.com/ apt/stable/" > /etc/apt/sources.list.d/sublime-text.list
            _verbose_cmd "apt update && apt install -y -V sublime-text"
            apt update && apt install -y -V sublime-text
            ;;
        arch)
            install_with_fallback "Sublime Text" "sublime-text" "sublime-text-4" "" "subl"
            return $?
            ;;
        fedora)
            _verbose_cmd "wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /usr/share/keyrings/sublimetext.gpg"
            wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /usr/share/keyrings/sublimetext.gpg
            dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
            _verbose_cmd "dnf install -y sublime-text"
            dnf install -y sublime-text
            ;;
    esac
    log_message "SUCCESS" "Sublime Text installed."
    log_version "Sublime Text" subl
}
