#!/usr/bin/env bash
# id: burpsuite
# name: Proxies
# desc: Burp Suite proxy.
# method: java
# pkg: burpsuite
# tags: security,web

install_burpsuite() {
    if command -v burpsuite &> /dev/null || [ -f "/opt/burpsuite/burpsuite.jar" ]; then
        log_message "WARN" "Burp Suite is already installed."
        return
    fi

    confirm_install "Burp Suite" "" "Download from portswigger.net" || return
    _check_deps "Burp Suite" java wget || return

    log_message "INFO" "Downloading Burp Suite Community Edition..."
    mkdir -p /opt/burpsuite
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} wget -O /opt/burpsuite/burpsuite.jar https://portswigger.net/burp/releases/download?product=community\&type=jar"
        echo -e "${YELLOW}[DRY-RUN]${NC} Create wrapper at /usr/local/bin/burpsuite"
        return 0
    fi
    _verbose_cmd "wget -O /opt/burpsuite/burpsuite.jar https://portswigger.net/burp/releases/download?product=community&type=jar"
    if ! wget --progress=bar:force -O /opt/burpsuite/burpsuite.jar "https://portswigger.net/burp/releases/download?product=community&type=jar"; then
        log_message "ERROR" "Failed to download Burp Suite from portswigger.net"
        log_message "INFO" "You can manually download it from: https://portswigger.net/burp/communitydownload"
        rm -f /opt/burpsuite/burpsuite.jar
        return 1
    fi

    if [ ! -s "/opt/burpsuite/burpsuite.jar" ]; then
        log_message "ERROR" "Downloaded Burp Suite file is empty. The URL may have changed."
        rm -f /opt/burpsuite/burpsuite.jar
        return 1
    fi

    cat > /usr/local/bin/burpsuite <<'WRAPPER'
#!/bin/sh
exec java -jar /opt/burpsuite/burpsuite.jar "$@"
WRAPPER
    chmod +x /usr/local/bin/burpsuite
    _verify_install "Burp Suite" burpsuite
    log_version "Burp Suite" "" burpsuite
}
