# id: thefuck
# name: thefuck
# desc: Command correction tool.
# method: apt
# pkg: thefuck
# tags: cli

install_thefuck() {
    if command -v thefuck &> /dev/null; then
        log_message "WARN" "thefuck is already installed."
        return
    fi
    confirm_install "thefuck" "thefuck" || return
    _check_deps "thefuck" python3 python3-pip || return
    if pkg_is_available thefuck; then
        pkg_install_native thefuck
    elif command -v pip3 &> /dev/null; then
        _verbose_cmd "pip3 install thefuck"
        pip3 install thefuck
    elif command -v pip &> /dev/null; then
        _verbose_cmd "pip install thefuck"
        pip install thefuck
    else
        log_message "ERROR" "thefuck is not available in repos. Install python3-pip and try again."
        return
    fi
    log_message "SUCCESS" "thefuck installed."
    log_version "thefuck" thefuck
}
