# id: docker
# name: Docker
# desc: Docker container runtime.
# method: apt
# pkg: docker.io
# tags: dev,container

install_docker() {
    if command -v docker &> /dev/null; then
        log_message "WARN" "Docker is already installed."
        return
    fi
    confirm_install "Docker" "docker" || return
    case $DISTRO in
        debian) pkg_install_native docker.io ;;
        arch|fedora) pkg_install_native docker ;;
    esac
    log_message "SUCCESS" "Docker installed."
    log_version "Docker" docker
}
