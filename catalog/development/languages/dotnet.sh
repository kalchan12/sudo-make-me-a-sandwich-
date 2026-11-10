# id: dotnet
# name: C# (.NET)
# desc: .NET runtime.
# method: apt
# pkg: dotnet-sdk
# tags: lang

install_dotnet() {
    if command -v dotnet &> /dev/null; then
        log_message "WARN" ".NET SDK is already installed."
        return
    fi
    confirm_install "C# (.NET)" "dotnet-sdk" || return
    case $DISTRO in
        debian)
            _verbose_cmd "wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb"
            wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
            _verbose_cmd "dpkg -i /tmp/packages-microsoft-prod.deb"
            dpkg -i /tmp/packages-microsoft-prod.deb && rm -f /tmp/packages-microsoft-prod.deb
            _verbose_cmd "apt update && apt install -y -V dotnet-sdk-8.0"
            apt update && apt install -y -V dotnet-sdk-8.0
            ;;
        arch) pkg_install_native dotnet-sdk ;;
        fedora) pkg_install_native dotnet-sdk-8.0 ;;
    esac
    log_message "SUCCESS" ".NET SDK installed."
    log_version ".NET" dotnet-sdk dotnet
}
