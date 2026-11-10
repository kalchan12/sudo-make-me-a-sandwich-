# id: firefox_dev
# name: Firefox Developer Edition
# desc: Pre-release Firefox for developers.
# method: deb_url
# pkg: firefox-dev
# tags: browser,mainstream,dev

install_firefox_dev() {
    if [ -d "/opt/firefox-developer" ] && [ -f "/opt/firefox-developer/firefox" ]; then
        log_message "WARN" "Firefox Developer Edition is already installed."
        return
    fi
    if command -v firefox-dev &> /dev/null; then
        log_message "WARN" "Firefox Developer Edition is already installed."
        return
    fi

    confirm_install "Firefox Developer Edition" "" "Download from mozilla.org" || return

    case $DISTRO in
        debian|fedora)
            rm -rf /opt/firefox-developer
            log_message "INFO" "Installing Firefox Developer Edition..."
            _verbose_cmd "wget -O /tmp/firefox-dev.tar.bz2 https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US"
            if ! wget --progress=bar:force -O /tmp/firefox-dev.tar.bz2 "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US"; then
                log_message "ERROR" "Failed to download Firefox Developer Edition"
                rm -f /tmp/firefox-dev.tar.bz2
                return
            fi
            tar xjf /tmp/firefox-dev.tar.bz2 -C /opt/
            mv /opt/firefox /opt/firefox-developer
            rm -f /tmp/firefox-dev.tar.bz2

            ln -sf /opt/firefox-developer/firefox /usr/local/bin/firefox-dev

            cat <<EOF > /usr/share/applications/firefox-developer.desktop
[Desktop Entry]
Name=Firefox Developer Edition
Exec=/opt/firefox-developer/firefox %u
Icon=/opt/firefox-developer/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOF
            ;;
        arch)
            install_with_fallback "Firefox Developer Edition" "" "firefox-developer-edition" "" "firefox-dev"
            return $?
            ;;
    esac
    log_message "SUCCESS" "Firefox Developer Edition installed."
    log_version "Firefox Developer Edition" "" firefox-dev
}
