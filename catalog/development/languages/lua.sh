#!/usr/bin/env bash
# id: lua
# name: Lua
# desc: Lua runtime.
# method: apt
# pkg: lua
# tags: lang

install_lua() {
    if command -v lua &> /dev/null; then
        log_message "WARN" "Lua is already installed."
        return
    fi
    confirm_install "Lua" "lua" || return
    install_with_fallback "Lua" "lua" "lua" "" "lua"
}
