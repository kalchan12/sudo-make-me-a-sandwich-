# id: bun
# name: Bun
# desc: Bun runtime.
# method: npm
# pkg: bun
# tags: dev,framework

install_bun() {
    if command -v bun &> /dev/null; then
        log_message "WARN" "Bun is already installed."
        return
    fi

    confirm_install "Bun" "bun" || return

    _verbose_cmd "curl -fsSL https://bun.sh/install | bash"
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"

    if command -v bun &> /dev/null; then
        log_message "SUCCESS" "Bun installed."
        log_version "Bun" bun bun
    else
        log_message "ERROR" "Bun installation failed."
    fi
}
