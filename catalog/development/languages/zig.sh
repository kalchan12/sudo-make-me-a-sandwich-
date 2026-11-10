# id: zig
# name: Zig
# desc: Zig runtime.
# method: apt
# pkg: zig
# tags: lang

install_zig() {
    if command -v zig &> /dev/null; then
        log_message "WARN" "Zig is already installed."
        return
    fi
    confirm_install "Zig" "zig" || return
    install_with_fallback "Zig" "zig" "zig" "" "zig"
}
