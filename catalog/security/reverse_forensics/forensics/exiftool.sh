# id: exiftool
# name: Stego & metadata
# desc: Metadata tool.
# method: perl
# pkg: libimage-exiftool-perl
# tags: security,forensics

install_exiftool() {
    if command -v exiftool &> /dev/null; then
        log_message "WARN" "exiftool is already installed."
        return
    fi
    confirm_install "exiftool" "libimage-exiftool-perl" || return
    case $DISTRO in
        debian) pkg_install_native libimage-exiftool-perl ;;
        arch) pkg_install_native perl-image-exiftool ;;
        fedora) pkg_install_native perl-Image-ExifTool ;;
        *) log_message "ERROR" "exiftool: unsupported distro ($DISTRO)"; return 1 ;;
    esac
    _verify_install "exiftool" exiftool
    log_version "exiftool" "" exiftool
}
