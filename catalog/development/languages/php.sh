# id: php
# name: PHP
# desc: PHP runtime.
# method: apt
# pkg: php
# tags: lang

install_php() {
    if command -v php &> /dev/null; then
        log_message "WARN" "PHP is already installed."
        return
    fi
    confirm_install "PHP" "php" || return
    pkg_install_native php
    log_message "SUCCESS" "PHP installed."
    log_version "PHP" php
}
