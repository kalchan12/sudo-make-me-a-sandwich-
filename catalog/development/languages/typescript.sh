# id: typescript
# name: TypeScript
# desc: TypeScript compiler.
# method: apt
# pkg: typescript
# tags: lang

install_typescript() {
    if command -v tsc &> /dev/null; then
        log_message "WARN" "TypeScript is already installed."
        return
    fi
    confirm_install "TypeScript" "" || return
    _check_deps "TypeScript" node npm || return
    if command -v npm &> /dev/null; then
        _verbose_cmd "npm install -g typescript"
        npm install -g typescript
        log_message "SUCCESS" "TypeScript installed."
        log_version "TypeScript" typescript tsc
    else
        log_message "ERROR" "npm is not available. Install Node.js first."
    fi
}
