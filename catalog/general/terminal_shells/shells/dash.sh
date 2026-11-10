#!/usr/bin/env bash
# id: dash
# name: Dash
# desc: POSIX shell.
# method: apt
# pkg: dash
# tags: shell

install_dash() {
    install_with_fallback "Dash" "dash" "dash" "" "dash"
}
