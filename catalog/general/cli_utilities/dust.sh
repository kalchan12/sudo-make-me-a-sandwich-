# id: dust
# name: dust
# desc: Disk usage analyzer.
# method: apt
# pkg: dust
# tags: cli

install_dust() {
    if command -v dust &> /dev/null; then
        log_message "WARN" "dust is already installed."
        return
    fi
    confirm_install "dust" "dust" || return
    case $DISTRO in
        debian) pkg_install_native du-dust ;;
        arch|fedora) pkg_install_native dust ;;
    esac
    log_message "SUCCESS" "dust installed."
    log_version "dust" dust
}
